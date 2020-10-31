# Homelab

Partial homelab setup with more to move to Ansible!

Currently only the Proxmox VMs are managed with Ansible, but ideally the rest of the lab would too.

## TODO 📝

Here is a (partial) list of TODOs:

+ [x] Install internal reverse proxy for Docker host (Traefik?)
+ [ ] Bring router and pfSense management into Ansible
+ [ ] Get rid of Bash script for Proxmox templating and either:
  + Create an Ansible role
  + Consider using [Packer's Proxmox Builder](https://www.packer.io/docs/builders/proxmox) which should be more flexible for preseeding and cloud-init
+ [ ] Manage observability tools with Ansible (Graylog, Prometheus, Grafana)
+ [ ] Pick (the hard part) and install a Wiki (WikiJS? Bookstack?), or stick with VimWiki
+ [ ] Scan with [gitleaks](https://github.com/zricethezav/gitleaks) using a git hook and not manually!