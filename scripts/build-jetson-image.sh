#!/usr/bin/env bash

# Author Badr @pythops

set -e

podman build \
	--cap-add=all \
	--jobs=4 \
	-f Containerfile.image \
	-t jetson-build-image

podman save -o build.tar localhost/jetson-build-image
sudo podman load -i build.tar

if [ "$1" == "jetson-nano" ]; then
	sudo podman run \
		--rm \
		--privileged \
		-v .:/jetson \
		-e JETSON_NANO_BOARD="jetson-nano" \
		-e JETSON_NANO_REVISION="$2" \
		localhost/jetson-build-image:latest \
		create-jetson-image.sh
else
	sudo podman run \
		--rm \
		--privileged \
		-v .:/jetson \
		-e JETSON_NANO_BOARD="jetson-nano-2gb" \
		localhost/jetson-build-image:latest \
		create-jetson-image.sh
fi

sudo rm -rf build.tar
