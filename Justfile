default:
    @just --list

build-jetson-rootfs:
    @scripts/build-base-rootfs.sh

buil-jetson-image board="":
    @scripts/build-jetson-image.sh
