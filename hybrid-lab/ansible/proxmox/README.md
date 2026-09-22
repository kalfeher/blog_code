## 1. Create the Ansible/Semaphore user

Create user `ansible`. The `@pve` represents the [PVE authentication realm](https://pve.proxmox.com/wiki/User_Management#pveum_authentication_realms)
```bash
pveum user add ansible@pve
```
Create group `ansibleGp`
```bash
pveum group add ansibleGp -comment "Ansible configuration tool users"
```
Add user `ansible@pve` to group `ansibleGp`
```bash
pveum user modify ansible@pve -group ansibleGp
```
Assign the role (`PVEAuditor`) to group `ansibleGp`.
```bash
pveum acl modify / -group ansibleGp -role PVEAuditor
```
Add API Token `ansible-01`. Set it to expire 180 days into the future. The output will include a _'one time only'_ display of the API key.
```bash
EXPIRE=$(date -d "+180 days" +%s)
pveum user token add ansible@pve ansible-01 --expire ${EXPIRE} --output-format yaml | grep -e "value:.*$"| cut -d ':' -f2 | tr -d ' '
# API Key is displayed as output
```
Ensure API token has the correct permissions
```bash
pveum acl modify / -token 'ansible@pve!ansible-01' -role PVEAuditor
```
## 2. Create Encrypted String for API Token
From the API Key displayed earlier
```bash
ansible-vault encrypt_string --vault-password-file /path/to/vault 'SuperStr0ngP@ssw0rd' --name 'token_secret'
```
Paste the result into `hosts.proxmox.yaml`.
## 3. Update Ansible Config File
Edit the file `ansible.cfg`. Add `community.proxmox.proxmox` to the inventory plugins.
```ini
# ansible.cfg
...
[inventory]
enable_plugins = community.proxmox.proxmox, host_list, script, yaml, ini, auto
...
```
## 4. Display Inventory Contents
```bash
ansible-inventory -i hosts.proxmox.yaml --vault-password-file ~/.ansible/vault --graph
```
You should see a tree layout of your Proxmox hosts and the groups they have been placed into.
