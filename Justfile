set positional-arguments

default:
    @just --list --unsorted

build-jetson-rootfs *args="":
    -@scripts/build-base-rootfs.sh {{ args }}

build-jetson-image *args="" :
    -@scripts/build-jetson-image.sh {{ args }}

flash-jetson-image Jetson-image device:
    @scripts/flash-jetson-image.sh {{ Jetson-image }} {{ device }}

clean:
    rm -rf base
    podman rmi -a -f
    sudo podman rmi -a -f
    sudo rm -rf jetson.img
