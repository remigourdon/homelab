#!/bin/bash
# Download an OS cloud image and create a Proxmox VM template from it
set -Eeuo pipefail

#########
# USAGE #
#########

usage() {
    echo "Usage: $(basename "${0}") [OPTIONS] VM_ID IMAGE

Download an OS cloud image and create a Proxmox VM template from it.

OPTIONS:
    -n NAME Name for the VM
    -s NAME Storage where the VM will be placed (default local-zfs)
    -r NUM  Resize for an additional NUM Gb on the disk (default 0)
    -u USER Default image user to set
    -k FILE SSH public key for default user
    -F      Destroy existing VM is ID is taken
    -h      Display this message"
}

###################
# OPTIONS PARSING #
###################

# Statics
TMP_DIR="/tmp"
MEMORY=1024
BRIDGE="vmbr0"

# Variables
VM_NAME=""
STORAGE="local-zfs"
RESIZE_GB=0
USER=""
KEY_FILE=""
FORCE=false

while getopts 'n:s:r:u:k:Fh' opts ; do
    case "${opts}" in
        n)
            VM_NAME="${OPTARG}"
            ;;
        s)
            STORAGE="${OPTARG}"
            ;;
        r)
            RESIZE_GB="${OPTARG}"
            ;;
        u)
            USER="--ciuser ${OPTARG}"
            ;;
        k)
            KEY_FILE="--sshkeys ${OPTARG}"
            ;;
        F)
            FORCE=true
            ;;
        h)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND - 1))"

################
# ARGS PARSING #
################

if [[ ${#} -ne 2 ]] ; then
    usage
    exit 1
else
    VM_ID="${1}"
    IMAGE="${2}"
fi

##########
# ACTION #
##########

# Get default name if none was specified
if [[ -z "${VM_NAME}" ]] ; then
    IMAGE_NAME="${IMAGE##*/}"
    VM_NAME="${IMAGE_NAME%%.*}"
fi

# Check if image is local
if [[ -e "${IMAGE}" ]] ; then
    IMAGE_PATH="${IMAGE}"
else
    # Make sure that the temporary file will always be delete
    trap 'rm -f ${IMAGE_PATH}' EXIT
    # Download image
    UUID="$(cat /proc/sys/kernel/random/uuid)"
    IMAGE_PATH="${TMP_DIR}/${UUID}"
    curl -L -o "${IMAGE_PATH}" "${IMAGE}"
fi

# Prepare description
DATE="$(date -u --iso-8601=second)"
DESC="Created on ${DATE} from ${IMAGE}"

# Check if ID is taken and destroy if forced
if qm config "${VM_ID}" >/dev/null 2>&1 ; then
    if [[ "${FORCE}" = true ]] ; then
        qm destroy "${VM_ID}" --purge
    fi
fi

# Create VM
qm create "${VM_ID}" \
  --memory "${MEMORY}" \
  --net0 virtio,bridge="${BRIDGE}" \
  --description "${DESC}" \
  --name "${VM_NAME}" ${USER} ${KEY_FILE}

# Import disk into VM (it will be unused for now)
qm importdisk "${VM_ID}" "${IMAGE_PATH}" "${STORAGE}" -format raw

# Attach the disk to the VM using VirtIO SCSI
qm set "${VM_ID}" --scsihw virtio-scsi-pci --scsi0 "${STORAGE}":vm-"${VM_ID}"-disk-0

# Set boot and display settings
qm set "${VM_ID}" --boot c --bootdisk scsi0 --serial0 socket --vga serial0

# Set DHCP
qm set "${VM_ID}" --ipconfig0 ip=dhcp

# Create cloud-init drive
qm set "${VM_ID}" --ide2 "${STORAGE}":cloudinit

# Set cloud-init type
qm set "${VM_ID}" --citype nocloud

# Increate the disk size
if [[ "${RESIZE_GB}" -gt 0 ]] ; then
  qm resize "${VM_ID}" scsi0 "+${RESIZE_GB}G"
fi

# Convert VM to template
qm template "${VM_ID}"
