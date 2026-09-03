# /hybrid-lab/tf/proxmox/lab.auto.tfvars
proxmox_host = "10.10.0.3"
proxmox_node_name = "proxmox01"
guest_vm_user = "semaphore"
guest_vm_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxxxxxxxxx ansible@hybridlab.example"
proxmox_tls_insecure = true
proxmox_user = "terraform@pve"
host_arch_ubuntu = "amd64"
