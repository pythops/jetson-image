#! /bin/bash

#
# Author: Badr BADRI © pythops
#

set -e

ARCH=arm64
RELEASE=bionic

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
	printf "\e[31mThis script requires root privilege\e[0m\n"
	exit 1
fi

# Check for env variables
if [ ! $JETSON_ROOTFS_DIR ]; then
	printf "\e[31mYou need to set the env variable \$JETSON_ROOTFS_DIR\e[0m\n"
	exit 1
fi

# Install prerequisites packages
printf "\e[32mInstall the dependencies...  "
apt-get update > /dev/null
apt-get install --no-install-recommends -y qemu-user-static debootstrap coreutils parted wget gdisk e2fsprogs > /dev/null
printf "[OK]\n"

# Create rootfs directory
printf "Create rootfs directory...    "
mkdir -p $JETSON_ROOTFS_DIR
printf "[OK]\n"

# Download ubuntu base image
if [ ! "$(ls -A $JETSON_ROOTFS_DIR)" ]; then
	printf "Download the base image...   "
  	wget -qO- http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.4/release/ubuntu-base-18.04.4-base-arm64.tar.gz | tar xzvf - -C $JETSON_ROOTFS_DIR > /dev/null
	printf "[OK]\n"
else
	printf "Base image already downloaded"
fi

# Run debootsrap first stage
printf "Run debootstrap first stage...  "
debootstrap \
        --arch=$ARCH \
        --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg \
        --foreign \
        --variant=minbase \
	--include=python3,libegl1,python3-apt \
        $RELEASE \
	$JETSON_ROOTFS_DIR > /dev/null
printf "[OK]\n"

# Copy qemu-aarch64-static
cp /usr/bin/qemu-aarch64-static $JETSON_ROOTFS_DIR/usr/bin

# Run debootstrap second stage
printf "Run debootstrap second stage... "
chroot $JETSON_ROOTFS_DIR /bin/bash -c "/debootstrap/debootstrap --second-stage"  > /dev/null
printf "[OK]\n"

printf "Success!\n"
