set positional-arguments

default:
    @just --list --unsorted

build-jetson-rootfs:
    @scripts/build-base-rootfs.sh

build-jetson-image *args="" :
    -@scripts/build-jetson-image.sh {{ args }}

flash-jetson-image Jetson-image device:
    @scripts/flash-jetson-image.sh {{ Jetson-image }} {{ device }}
