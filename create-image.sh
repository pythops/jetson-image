#! /bin/bash

#
# Author: Badr BADRI © pythops
# 

set -e

BSP=https://developer.nvidia.com/embedded/r32-2-3_Release_v1.0/t210ref_release_aarch64/Tegra210_Linux_R32.2.3_aarch64.tbz2

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
        printf "\e[31mThis script requires root privilege\e[0m\n"
        exit 1
fi

# Check for env variables
if [ ! $JETSON_ROOTFS_DIR ] || [ ! $JETSON_BUILD_DIR ]; then
	printf "\e[31mYou need to set the env variables \$JETSON_ROOTFS_DIR and \$JETSON_BUILD_DIR\e[0m\n"
	exit 1
fi

# Check if $JETSON_ROOTFS_DIR if not empty
if [ ! "$(ls -A $JETSON_ROOTFS_DIR)" ]; then
	printf "\e[31mNo rootfs found in $JETSON_ROOTFS_DIR\e[0m\n"
	exit 1
fi

printf "\e[32mBuild the image ...\n"

# Create the build dir if it does not exists
mkdir -p $JETSON_BUILD_DIR

# Download L4T
if [ ! "$(ls -A $JETSON_BUILD_DIR)" ]; then
        printf "\e[32mDownload L4T...       "
        wget -qO- $BSP | tar -jxpf - -C $JETSON_BUILD_DIR
	rm $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/README.txt
        printf "[OK]\n"
fi

cp -rp $JETSON_ROOTFS_DIR/*  $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/ > /dev/null

pushd $JETSON_BUILD_DIR/Linux_for_Tegra/ > /dev/null

printf "Extract L4T...        "
./apply_binaries.sh > /dev/null
printf "[OK]\n"

printf "Create image...       "
rootfs_size=$(du -hsBM $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs | awk '{print $1}')
rootfs_size=$(echo $((${rootfs_size%?} + 200))"M")
./create-jetson-nano-sd-card-image.sh -o jetson.img -s $rootfs_size -r 200
printf "OK\n"

printf "\e[32mImage created successfully\n"
printf "Image location: $JETSON_BUILD_DIR/Linux_for_Tegra/jetson.img\n"
