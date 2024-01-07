#!/usr/bin/env bash

# Author Badr @pythops

set -e

echo "Building base rootfs"

if [ "$1" != "22.04" ] && [ "$1" != "20.04" ]; then
    echo "Error: Unknow version of ubuntu. The supported versions are: 20.04 or 22.04"
    exit 1
fi

if [ "$1" == "20.04" ]; then
    podman build \
        --squash-all \
        --jobs=4 \
        --arch=arm64 \
        -f Containerfile.rootfs.20_04 \
        -t jetson-rootfs
elif [ "$1" == "22.04" ]; then
    podman build \
        --squash-all \
        --jobs=4 \
        --arch=arm64 \
        -f Containerfile.rootfs.22_04 \
        -t jetson-rootfs
else
    exit 1
fi

podman save --format docker-dir -o base jetson-rootfs

mkdir rootfs

for layer in $(jq -r '.layers[].digest' base/manifest.json | awk -F ':' '{print $2}'); do
    tar xvf base/"$layer" --directory=rootfs
done

rm -rf rootfs/root/.bash_history

rm -rf base

echo "Rootfs created in rootfs directory"
