#!/usr/bin/env bash

# Author Badr @pythops

set -e

echo "Building base rootfs"

if [ "$1" != "24.04" ] && [ "$1" != "22.04" ] && [ "$1" != "20.04" ]; then
  echo "Error: Unknow version of ubuntu. The supported versions are: 20.04, 22.04, 24.04"
  exit 1
fi

case $1 in
"20.04")
  podman build \
    --squash-all \
    --jobs=4 \
    --arch=arm64 \
    -f Containerfile.rootfs.20_04 \
    -t jetson-rootfs
  ;;

"22.04")
  podman build \
    --squash-all \
    --jobs=4 \
    --arch=arm64 \
    -f Containerfile.rootfs.22_04 \
    -t jetson-rootfs
  ;;

"24.04")
  podman build \
    --squash-all \
    --jobs=4 \
    --arch=arm64 \
    -f Containerfile.rootfs.24_04 \
    -t jetson-rootfs
  ;;

*)
  exit 1
  ;;
esac

podman save --format docker-dir -o base jetson-rootfs

mkdir rootfs

for layer in "$(jq -r '.layers[].digest' base/manifest.json | awk -F ':' '{print $2}')"; do
  tar xvf base/"$layer" --directory=rootfs
done

rm -rf rootfs/root/.bash_history

rm -rf base

echo "Rootfs created in rootfs directory"
