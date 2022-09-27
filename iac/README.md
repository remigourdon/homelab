# Infrastructure as Code

## Create cloud image template in Proxmox

Use the script as follows:

```sh
./create-proxmox-template.sh \
    root@pve-1 \
    https://cloud-images.ubuntu.com/jammy/20220924/jammy-server-cloudimg-amd64.img \
    8000 \
    ~/.ssh/id_ed25519.pub
```