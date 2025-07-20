#!/usr/bin/env bash

# https://releases.ubuntu.com/noble/SHA256SUMS

BASEDIR=`mktemp -d`
VM_NAME="${1}"

if [ -z "${VM_NAME}"]; then
    VM_NAME=packer_`date +"%Y%m%d%H%M%S"`
fi

cp -R packer/* $BASEDIR

# Generate a random high port number between 49152 and 65535
min_port=49152
max_port=65535
range=$((max_port - min_port + 1))
ssh_nat_port=$((RANDOM % range + min_port))

pushd $BASEDIR
    cat > Ubuntu24_LTS_64.auto.pkrvars.hcl << EOF
iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-desktop-amd64.iso"
iso_checksum = "sha256:d7fe3d6a0419667d2f8eff12796996328daa2d4f90cd9f87aa9371b362f987bf"
headless = false
vm_name = "${VM_NAME}"
ssh_nat_port = ${ssh_nat_port}
EOF

    packer init .
    packer build .

    # /usr/bin/VBoxManage modifyvm "${VM_NAME}" --natpf1 delete "guestssh"
    # /usr/bin/VBoxManage setextradata "${VM_NAME}" "VBoxInternal/TM/TSCTiedToExecution" 1
    # /usr/bin/VBoxManage setextradata "${VM_NAME}" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1
    # /usr/bin/VBoxManage guestproperty set "${VM_NAME}" "/VirtualBox/GuestAdd/SyncTime" 0

    pwd

    ls -hrl ./output-ubuntu_builder/

popd

echo -e "\ncd ${BASEDIR}/output-ubuntu_builder/\n"
