# /hybrid-lab/tf/proxmox/main.tf
resource "random_pet" "vm_name" {
  length    = 2
  separator = "-"
}
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "ubuntu-${random_pet.vm_name.id}"
  node_name = var.proxmox_node_name
  tags = ["arc", "ubuntu", "terraform"]
  description = "Ubuntu VM created by Terraform"
  # should be true if qemu agent is not installed / enabled on the VM
  # This image does not have qemu pre-installed.
  stop_on_destroy = true
  initialization {
    user_account {
      # Creds for ansible
      username = "${var.guest_vm_user}"
      keys = ["${var.guest_vm_ssh_key}"]
    }
  }
  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
  memory {
    dedicated = 2048
  }
  cpu {
    sockets         = 1
    cores           = 2
    type            = "host"
  }
}
resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = "${var.ubuntu_cloud_img_url}${var.ubuntu_cloud_img_release}-${var.host_arch_ubuntu}.img"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "${var.ubuntu_cloud_img_release}-${var.host_arch_ubuntu}.qcow2"
}
