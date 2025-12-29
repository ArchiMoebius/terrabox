#!/bin/bash

D=`mktemp -d`
python3 -mvenv $D
source $D/bin/activate
python3 -mpip install -U ansible

echo -e "\n[+] Running Ansible: $@\n"

ANSIBLE_REMOTE_TMP=/tmp/.ansible/tmp ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 $D/bin/ansible-playbook "$@"
