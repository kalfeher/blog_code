The files in this folder should be encrypted using ansible vault. 

**Do not check in unencrypted files into your repo!**

```bash
ansible-vault encrypt /hybrid-lab/tf/proxmox/ans_vault/pve_api.yml --vault-pass-file ~/.ansible/vault_pass
ansible-vault encrypt /hybrid-lab/tf/proxmox/ans_vault/pve_pass.yml --vault-pass-file ~/.ansible/vault_pass
```