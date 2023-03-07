#!/usr/bin/env bash

# Author Badr @pythops

set -e

podman build \
	--cap-add=all \
	--cache-ttl=1h \
	--jobs=4 \
	-f Containerfile.image \
	-t jetson-build-image

# Temporary
podman save -o build.tar localhost/jetson-build-image
sudo podman load -i build.tar

sudo podman run \
	--user root \
	--device-cgroup-rule="b 7:* rwm" \
	--device /dev/loop-control:/dev/loop-control:rwm \
	--privileged \
	--cap-add=all \
	--rm \
	-it \
	-v .:/jetson \
	-e JETSON_NANO_BOARD="jetson-nano" \
	localhost/jetson-build-image:latest \
	create-jetson-image.sh
