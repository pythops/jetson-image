#!/usr/bin/env bash

# Author Badr @pythops

set -e

if [ "$1" != "jetson-nano" ] && [ "$1" != "jetson-nano-2gb" ]; then
	echo "Unsupported board {{ board }}"
	echo "The only supported boards are:"
	echo "- jetson-nano"
	echo "- jetson-nano-2gb"
	exit
fi

if [ "$1" == "jetson-nano" ]; then
	if [ "$2" != "300" ] && [ "$2" != "200" ]; then
		echo "Unknown revision for Jetson nano board"
		echo "Supported revision: 200 or 300"
		exit
	fi
	echo "Building for Jetson nano board revision $2"
else
	echo "Building for jetson-nano-2gb board"
fi

sudo -E podman build \
	--cap-add=all \
	--jobs=4 \
	-f Containerfile.image \
	-t jetson-build-image

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
