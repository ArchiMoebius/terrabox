#!/bin/bash -eu

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
sudo apt-get -y autoremove --purge
sudo apt-get -y clean

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/user/.bash_history

#  Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clean cfg files  created by AutoInstall
FILE=/etc/cloud/cloud.cfg.d/50-curtin-networking.cfg
if test -f "$FILE"; then
  sudo rm $FILE
fi

FILE=/etc/cloud/cloud.cfg.d/curtin-preserve-sources.cfg
if test -f "$FILE"; then
  sudo rm $FILE
fi

FILE=/etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
if test -f "$FILE"; then
  sudo rm $FILE
fi

# Zero out the free space to save space in the final image
if [ -d /boot/efi ]; then
    dd if=/dev/zero of=/boot/efi/EMPTY bs=1M || echo "dd exit code $? is suppressed"
    rm -f /boot/efi/EMPTY
fi
dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed"
rm -f /EMPTY
sync

echo "==> Disk usage after cleanup"
df -h

sudo init 0