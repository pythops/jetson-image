#!/usr/bin/env bash

# Author: Badr @pythops

case "$JETSON_NANO_BOARD" in
jetson-nano-2gb)
	printf "Create image for Jetson nano 2GB board... "
	sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit
	cp jetson.img /jetson/
	printf "[OK]\n"
	;;

jetson-nano)
	nano_board_revision=${JETSON_NANO_REVISION:=300}
	printf "Creating image for Jetson nano board (%s revision)... " $nano_board_revision
	sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r $nano_board_revision
	cp jetson.img /jetson
	printf "[OK]\n"
	;;

*)
	printf "\e[31mUnknown Jetson nano board type\e[0m\n"
	exit 1
	;;
esac
