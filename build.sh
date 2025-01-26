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
iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-desktop-amd64.iso"
iso_checksum = "sha256:c2e6f4dc37ac944e2ed507f87c6188dd4d3179bf4a3f9e110d3c88d1f3294bdc"
headless = false
vm_name = "${VM_NAME}"
ssh_nat_port = ${ssh_nat_port}
EOF

    packer init .
    packer build .
    # /usr/bin/vboxmanage modifyvm "${VM_NAME}" --natpf1 delete "guestssh"
    pwd
    ls -hrl ./output-ubuntu_builder/

popd

echo -e "\ncd ${BASEDIR}/output-ubuntu_builder/\n"
