default:
    @just --list --unsorted

build-jetson-rootfs:
    @scripts/build-base-rootfs.sh

build-jetson-image board revision="300":
    @scripts/build-jetson-image.sh {{ board }} {{ revision }}

flash-jetson-image Jetson-image device:
    @scripts/flash-jetson-image.sh {{ Jetson-image }} {{ device }}
