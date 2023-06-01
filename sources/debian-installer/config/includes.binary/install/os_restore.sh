#! /bin/sh

set -e

# unpack OS files
echo "Unpacking OS files..."
mkdir /os-install
cd /os-install
tar zxvf /cdrom/optware/debian*
tar zxvf data.tar.gz
cd opt/var/lib/debian

if [ -e /sys/firmware/efi ]
then
  echo "Configuring EFI system..."
  
  dd if=bootable.iso of=/dev/sda bs=8M
else
  echo "Configuring BIOS system..."
  
  # write bootloader
  dd if=boot.img of=/dev/sda
  sleep 1
  sync
  sleep 1

  # write root partition
  blockdev --rereadpt /dev/sda
  sleep 1
  dd if=root.img of=/dev/sda1 bs=8M
  sync
fi

echo "Rebooting to setup partitions"
reboot