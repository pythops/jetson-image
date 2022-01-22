#! /bin/bash

#
# Author: Badr BADRI © pythops
#

set -e

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
	printf "\e[31mThis script requires root privilege\e[0m\n"
	exit 1
fi

# Check the arguments
if [ "$#" -ne 2 ]; then
	echo "flash-image.sh </path/to/jetson.img> </path/to/sdcard>"
	echo "example: ./flash-image.sh /tmp/jetson.img /dev/mmcblk0"
	exit 1
fi

# Check that $2 is a block device
if [ ! -b "$2" ] || [ "$(lsblk | grep -w $(basename $2) | awk '{print $6}')" != "disk" ]; then
	printf "\e[31m$2 is not a block device\e[0m\n"
	exit 1
fi

# Check jetson image file
if [ ! -e "$1" ] || [ ! -s "$1" ]; then
	printf "\e[31m$1 does not exist or has 0 B in size\e[0m\n"
	exit 1
fi

# Unmount sdcard
if [ "$(mount | grep $2)" ]; then
	printf "\e[32mUnmount SD card... "
	for mount_point in $(mount | grep $2 | awk '{ print $1}'); do
		sudo umount $mount_point > /dev/null
	done
	printf "[OK]\e[0m\n"
fi

# Flash image
printf "\e[32mFlash the sdcard... \e[0m"
dd if=$1 of=$2 bs=4M conv=fsync status=progress
printf "\e[32m[OK]\e[0m\n"

# Extend the partition
printf "\e[32mExtend the partition... "
partprobe $2 &> /dev/null

sgdisk -e $2 > /dev/null

end_sector=$(sgdisk -p $2 |  grep -i "Total free space is" | awk '{ print $5 }')
start_sector=$(sgdisk -i 1 $2 | grep "First sector" | awk '{print $3}')

# Recrate the partition
sgdisk -d 1 $2 > /dev/null

sgdisk -n 1:$start:$end $2 > /dev/null

sgdisk -c 1:APP $2 > /dev/null

printf "[OK]\e[0m\n"

# Extend fs
printf "\e[32mExtend the fs... "
if [[ $2 =~ .*mmcblk.* ]]; then
    e2fsck -fp $2"p1" > /dev/null
    resize2fs $2"p1" > /dev/null
else
    e2fsck -fp $2"1" > /dev/null
    resize2fs $2"1" > /dev/null
fi
sync
printf "[OK]\e[0m\n"

printf "\e[32mSuccess!\n"
printf "\e[32mYour sdcard is ready!\n"
