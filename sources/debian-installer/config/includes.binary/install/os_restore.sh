#! /bin/sh

set -e

# unpack OS files
mkdir /os-install
cd /os-install
tar zxvf /cdrom/optware/debian*
tar zxvf data.tar.gz
cd opt/var/lib/debian

if [ -e /sys/firmware/efi ]
then
  echo "Configuring EFI system"
  
  if ! blkid | grep sda;
  then
    echo "No disk label"
    echo "Making gpt disk label..."
    parted /dev/sda mklabel gpt
  fi
  
  # Delete existing boot/rootfs partitions, ignore "partition doesn't exist" errors
  set +e
  parted /dev/sda rm 1 2>/dev/null
  parted /dev/sda rm 2 2>/dev/null
  parted /dev/sda rm 3 2>/dev/null
  set -e
  
  echo "Creating partition 1 - EFI - 512Mb"
  parted /dev/sda mkpart EFI 2048s 1050623s
  
  echo "Creating partition 2 - rootfs(1) - 2Gb"
  parted /dev/sda mkpart rootfs1 1050624s 5244927s
  
  echo "Creating partition 2 - rootfs(2) - 2Gb"
  parted /dev/sda mkpart rootfs2 5244928s 9439231s
  
  echo "Writing EFI boot partition..."
  dd if=boot.iso of=/dev/sda1
  
  echo "Writing rootfs partition..."
  dd if=root.iso of=/dev/sda2 bs=8M
else
  echo "Configuring BIOS system"
  
  # write bootloader
  dd if=boot.img of=/dev/sda
  sleep 0.2
  sync
  sleep 0.2

  # write root partition
  blockdev --rereadpt /dev/sda
  sleep 1
  dd if=root.img of=/dev/sda1 bs=8M
  sync
fi

reboot