# /hybrid-lab/tf/proxmox/providers.tf
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.111.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.9.0"
    }
    ansible = {
      version = ">=1.5.0"
      source  = "ansible/ansible"
    }
  }
}
provider "ansible" {
  # Configuration options
}
ephemeral "ansible_vault" "pve_api" {
  vault_file = "ans_vault/pve_api.yml"
  vault_password_file = "~/.ansible/vault"
}
provider "proxmox" {
  endpoint      = "https://${var.proxmox_host}:8006/"
  api_token    = yamldecode(ephemeral.ansible_vault.pve_api.yaml)
  # password = yamldecode(ephemeral.ansible_vault.pve_password.yaml)
  username     = var.proxmox_user
  insecure = var.proxmox_tls_insecure
}
provider "random" {
  # Configuration options
}
