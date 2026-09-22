# /hybrid-lab/tf/proxmox/main.tf
# Create cloud-init file for the Ubuntu VM
resource "proxmox_virtual_environment_file" "lab_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  
  source_raw {
    data = <<-EOF
    #cloud-config
    packages:
    - qemu-guest-agent
    timezone: Australia/Melbourne
    ssh_pwauth: false
    write_files:
    - path: /etc/ssh/sshd_config.d/70-no-pam-password-auth.conf
      content: 'KbdInteractiveAuthentication no'
      permissions: '0500'
    users:
    - name: ${var.guest_vm_user}
      gecos: Ansible User
      groups: users,sudo
      sudo: "ALL=(ALL) NOPASSWD:ALL"
      shell: /bin/bash
      lock_passwd: true
      ssh_authorized_keys:
        - "${trimspace(var.guest_vm_ssh_key)}"
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF
    file_name = "lab.cloud-config.yaml"
  }
}
resource "random_pet" "vm_name" {
  length    = 2
  separator = "-"
}
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "ubuntu-${random_pet.vm_name.id}"
  node_name = var.proxmox_node_name
  tags = ["arc", "ubuntu", "terraform"]
  description = "Ubuntu VM created by Terraform"
  agent {
    enabled = true
  }
  # should be true if qemu agent is not installed / enabled on the VM
  # stop_on_destroy = true
  # This image will have qemu agent pre-installed.
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        # This will use SLAAC. Alternatively use "dhcp" for DHCP6
        address = "auto"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.lab_data.id
  }
  network_device {
    model = "virtio"
    bridge = "vmbr0"
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
