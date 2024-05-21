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
if [ ! -b "$2" ] || [ "$(lsblk | grep -w "$(basename "$2")" | awk '{print $6}')" != "disk" ]; then
  printf "\e[31m$2 is not a block device\e[0m\n"
  exit 1
fi

# Check jetson image file
if [ ! -e "$1" ] || [ ! -s "$1" ]; then
  printf "\e[31m$1 does not exist or has 0 B in size\e[0m\n"
  exit 1
fi

# Unmount sdcard
if [ "$(mount | grep "$2")" ]; then
  printf "\e[32mUnmount SD card... "
  for mount_point in "$(mount | grep "$2" | awk '{ print $1}')"; do
    sudo umount "$mount_point" >/dev/null
  done
  printf "[OK]\e[0m\n"
fi

# Flash image
printf "\e[32mFlash the sdcard... \e[0m"
dd if="$1" of="$2" bs=128M conv=fsync status=progress
printf "\e[32mDevice ready!\n"
