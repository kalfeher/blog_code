The code in this directory is shown in the article [A simple CA using CFSSL](https://kalfeher.com/simple-CA-with-CFSSL/).
## Install CFSSL on Ubuntu
Only Ubuntu is supported for now. But it should be trivial to update the Ansible code to support other OSes.
To install:
```bash
# you can override the default host group using -e "target=blah"
ansible-playbook cfssl/install.yaml -e "target=my_group"
```