# TerraBox

Type `make` to create a nice VirtualBox OVA with some pre-baked HTB tools.

## Development

Create an inventory file `/tmp/i` - holding the IP address of the thing you want to run the playbook on.

```bash
cd packer/ansible

ansible-playbook main.yml -i /tmp/i --extra-vars "vm_name=htb_nov_2 ansible_user=user ansible_password=password ansible_sudo_pass=password"
```
