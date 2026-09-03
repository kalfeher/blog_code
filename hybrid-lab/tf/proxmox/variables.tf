# /hybrid-lab/tf/proxmox/variables.tf
variable "proxmox_user" {
  type = string
  description = "Proxmox user for authentication"
  sensitive = true
  ephemeral = true
}
variable "guest_vm_user" {
  type = string
  description = "Username for the guest VM"
  sensitive = true
}
variable "guest_vm_ssh_key" {
  type = string
  description = "Orchestration tool SSH key for the guest VM"
}
variable "ubuntu_cloud_img_url" {
  type = string
  default = "https://cloud-images.ubuntu.com/resolute/current/"
}
variable "ubuntu_cloud_img_release" {
  type = string
  default = "resolute-server-cloudimg"
}
variable "proxmox_host" {
  type = string
  description = "Proxmox host for the API endpoint"
}
variable "proxmox_tls_insecure" {
  type = bool
  description = "Whether to skip TLS verification for the Proxmox API"
}
variable "host_arch_ubuntu" {
  type = string
  description = "Architecture of the Ubuntu host"
}
variable "proxmox_node_name" {
  type = string
  description = "Name of the Proxmox node"
}
