#!/usr/bin/env bash

# https://releases.ubuntu.com/noble/SHA256SUMS

BASEDIR=`mktemp -d`

cp -R packer/* $BASEDIR

pushd $BASEDIR
    cat > Ubuntu24_LTS_64.auto.pkrvars.hcl << EOF
iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-desktop-amd64.iso"
iso_checksum = "sha256:c2e6f4dc37ac944e2ed507f87c6188dd4d3179bf4a3f9e110d3c88d1f3294bdc"
headless = false
vm_name = "${1}"
EOF

    packer init .
    packer build .
    pwd
    ls -hrl ./output-ubuntu_builder/

popd

echo -e "\ncd ${BASEDIR}/output-ubuntu_builder/\n"
