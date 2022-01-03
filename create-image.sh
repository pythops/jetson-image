#! /bin/bash

#
# Author: Badr BADRI © pythops
#

set -e

BSP=https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2

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

# Check if board type is specified
if [ ! $JETSON_NANO_BOARD ]; then
	printf "\e[31mJetson nano board type must be specified\e[0m\n"
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

printf "Applying patches...   "
patch $JETSON_BUILD_DIR/Linux_for_Tegra/nv_tegra/nv-apply-debs.sh < patches/nv-apply-debs.diff > /dev/null
printf "[OK]\n"

pushd $JETSON_BUILD_DIR/Linux_for_Tegra/ > /dev/null

printf "Extract L4T...        "
./apply_binaries.sh &> /dev/null
popd > /dev/null
printf "[OK]\n"

pushd $JETSON_BUILD_DIR/Linux_for_Tegra/tools > /dev/null

case "$JETSON_NANO_BOARD" in
    jetson-nano-2gb)
        printf "Create image for Jetson nano 2GB board... "
        ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit &> /dev/null
        popd > /dev/null
        cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img . > /dev/null
        printf "[OK]\n"
        ;;

    jetson-nano)
        nano_board_revision=${JETSON_NANO_REVISION:=300}
        printf "Creating image for Jetson nano board (%s revision)... " $nano_board_revision
        ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r $nano_board_revision &> /dev/null
        popd > /dev/null
        cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img . > /dev/null
        printf "[OK]\n"
        ;;

    *)
	printf "\e[31mUnknown Jetson nano board type\e[0m\n"
	exit 1
        ;;
esac

printf "\e[32mImage created successfully\n"
printf "Image location ./jetson.img\n"
