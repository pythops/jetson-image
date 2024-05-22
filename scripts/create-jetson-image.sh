#!/usr/bin/env bash

# Author: Badr @pythops

case "$JETSON_BOARD" in
jetson-nano-2gb)
  printf "Create image for Jetson nano 2GB board \n"
  sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit
  cp jetson.img /jetson/
  printf "[OK]\n"
  ;;

jetson-nano)
  printf "Creating image for Jetson nano board (%s revision) \n" "$JETSON_REVISION"
  sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r "$JETSON_REVISION"
  cp jetson.img /jetson/
  printf "[OK]\n"
  ;;

jetson-orin-nano)
  printf "Creating image for Jetson orin nano board \n"
  sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-orin-nano-devkit -d "$JETSON_DEVICE"
  cp jetson.img /jetson/
  printf "[OK]\n"
  ;;

jetson-xavier-nx)
  printf "Creating image for Jetson xavier nx board \n"
  sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-xavier-nx-devkit -d "$JETSON_DEVICE"
  cp jetson.img /jetson/
  printf "[OK]\n"
  ;;

jetson-agx-xavier)
  printf "Creating image for Jetson agx xavier board \n"
  sudo ./jetson-disk-image-creator.sh -o jetson.img -b jetson-agx-xavier-devkit -d "$JETSON_DEVICE"
  cp jetson.img /jetson/
  printf "[OK]\n"
  ;;

*)
  printf "\e[31mUnsupported Jetson board. \e[0m\n"
  exit 1
  ;;
esac
