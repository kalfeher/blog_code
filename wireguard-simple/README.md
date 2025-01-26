This folder contains code examples and scripts for the [wireguard-simple](https://kalfeher.com/wireguard-simple) blog.

Vault files are unencrypted to show what their contents should look like. Once you have updated their contents you must encrypt them using the following command:
```bash
ansible-vault encrypt vault/vpn_vault.yml
```
Placeholder values may cause configuration errors if not removed before attempting to update applications. Be sure to review all files before using.