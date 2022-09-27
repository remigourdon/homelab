#!/usr/bin/env bash
set -Eeuo pipefail

###############
# DEFINITIONS #
###############

VM_POOL="local-zfs"

#########
# USAGE #
#########

usage() {
    echo "Usage: $(basename "${0}") [OPTIONS] SSH_HOST IMG_URL TEMPLATE_ID CLOUDINIT_SSH_PUB

Create VM template from a cloud image.

OPTIONS:
    -h    Display this message"
}

################
# ARGS PARSING #
################

if [[ ${#} -ne 4 ]] ; then
    usage
    exit 1
else
    SSH_HOST="${1}"
    IMG_URL="${2}"
    TEMPLATE_ID="${3}"
    CLOUDINIT_SSH_PUB="${4}"

    IMG_NAME="$(basename "${IMG_URL}")"
fi

##########
# ACTION #
##########

# Copy SSH public keys to Proxmox
CLOUDINIT_SSH_PUB_PROXMOX="${IMG_NAME%.img}-ssh.pub"
scp -q "${CLOUDINIT_SSH_PUB}" "${SSH_HOST}":"${CLOUDINIT_SSH_PUB_PROXMOX}"

ssh -T "${SSH_HOST}" <<EOI

# Get image from URL (won't redownload if already there)
wget --continue --quiet "${IMG_URL}"

# Create and configure VM (exit if already exists)
qm create "${TEMPLATE_ID}" \
    --name "${IMG_NAME%.img}" \
    --description "${IMG_NAME%.img} (created on $(date --utc --iso-8601=seconds))" \
    --memory 2048 \
    --core 2 \
    --net0 virtio,bridge=vmbr0 \
    --serial0 socket --vga serial0 \
    --boot "order=scsi0;ide2;net0" || exit 1

# Import and mount cloud image disk
qm importdisk "${TEMPLATE_ID}" "${IMG_NAME}" "${VM_POOL}"
qm set "${TEMPLATE_ID}" \
    --scsihw virtio-scsi-pci \
    --scsi0 "${VM_POOL}:vm-${TEMPLATE_ID}-disk-0"

# Configure Cloud-Init
qm set "${TEMPLATE_ID}" \
    --ide2 "${VM_POOL}:cloudinit" \
    --ciuser "server-admin" \
    --sshkeys "${CLOUDINIT_SSH_PUB_PROXMOX}" \
    --ipconfig0 ",ip=dhcp"

# Create template from this VM
qm template "${TEMPLATE_ID}"
EOI