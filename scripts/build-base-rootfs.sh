#!/usr/bin/env bash

# Author Badr @pythops

set -e

echo "Building base rootfs"

podman build \
	--layers \
	--squash-all \
	--jobs=4 \
	--arch=arm64 \
	-f Containerfile.rootfs \
	-t jetson-nano-base-image

podman save --format docker-dir -o base jetson-nano-base-image

mkdir rootfs

for layer in $(jq -r '.layers[].digest' base/manifest.json | awk -F ':' '{print $2}'); do
	tar xvf base/"$layer" --directory=rootfs
done

echo "nameserver 8.8.8.8" >rootfs/etc/resolv.conf
rm -rf rootfs/root/.bash_history

rm -rf base

echo "Rootfs created in rootfs directory"
