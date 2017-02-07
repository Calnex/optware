#! /bin/bash

set -e

OLD_PARTITION=$(fdisk -l /dev/sda | awk '$2 == "*" {print $1}')

if [[ ${OLD_PARTITION} != "/dev/sda1" ]]
then
    echo "Unexpected partition layout!"
    exit
fi

if [[ -f /opt/var/lib/debian/boot.img ]]
then
    cd /opt/var/lib/debian/
else
    echo "Cannot find OS insatllation files."
    echo "Please install Debian package as calnex"
    exit
fi

# write bootloader
dd if=boot.img of=/dev/sda >/dev/null 2>&1
sync

echo "Bootloader installed"

NEW_PARTITION_START=2099200
IMG_SIZE=$(ls -l root.img | awk '{print $5}')

# ignore errors from here on
set +e

parted /dev/sda --script mkpart primary ext2 ${NEW_PARTITION_START}s $((${NEW_PARTITION_START} + ($IMG_SIZE/512)))s >/dev/null 2>&1
# re-read partition table
blockdev --rereadpt /dev/sda >/dev/null 2>&1

# write root partition
dd if=root.img of=/dev/sda2 bs=8M >/dev/null 2>&1
sync
echo "OS installed"

parted /dev/sda --script toggle 2 boot -- >/dev/null 2>&1

echo "Rebooting"

sync
reboot
