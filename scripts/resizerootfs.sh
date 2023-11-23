#!/usr/bin/env bash

set -e

rootpart="/dev/$(lsblk -l -o NAME,MOUNTPOINT | grep '/' | awk '{print $1}')"
rootdevice="/dev/$(lsblk -no pkname "$rootpart")"

partprobe "$rootdevice"

echo ", +" | sfdisk -f -N 1 "$rootdevice"

resize2fs "$rootpart"

partprobe "$rootdevice"
