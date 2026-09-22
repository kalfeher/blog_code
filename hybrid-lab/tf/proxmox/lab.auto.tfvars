# /hybrid-lab/tf/proxmox/lab.auto.tfvars
proxmox_host = "10.10.0.3"
proxmox_node_name = "proxmox01"
guest_vm_user = "semaphore"
# This is a public key. It is safe to include here without encryption
guest_vm_ssh_key = "ssh-ed25519 AAAACXXXXXXXXXXXXXXX ansible@hybridlab.example"
proxmox_tls_insecure = true
proxmox_user = "terraform@pve"
proxmox_ssh_user      = "terraform"
# This file contains a private key. Never include its contents here
proxmox_ssh_key       = "~/.ssh/tf_ed25519"
host_arch_ubuntu = "amd64"

