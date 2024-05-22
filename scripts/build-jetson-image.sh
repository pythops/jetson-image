#!/usr/bin/env bash

# Author Badr @pythops

set -e

supported_boards=("jetson-nano" "jetson-nano-2gb" "jetson-orin-nano" "jetson-agx-xavier" "jetson-xavier-nx")

function usage() {
  echo "Usage: $0 -b <board> -r <revision> -d <device> -l <l4t>"
  echo ""
  echo "board: the board name, one of the following names:"
  for supported_board in "${supported_boards[@]}"; do
    echo "    ${supported_board}"
  done
  echo ""
  echo "revision: the revision number. Only required for jetson-nano board. The possible values are: 100, 200 or 300."
  echo ""
  echo "device: the rootfs device SD/USB. Only required for the following boards:"
  echo "    - jetson-orin-nano"
  echo "    - jetson-agx-xavier"
  echo "    - jetson-xavier-nx"
  echo ""
  echo "l4t version. The possible values are: 32, 35, 36"
  exit 1
}

while getopts b:r:d:l:h opts; do
  case "$opts" in

  b)
    board=${OPTARG}
    if [[ ! " ${supported_boards[@]} " =~ " ${board} " ]]; then
      printf "\e[31mError: Unsupported board: %s \n\e[0m" "$board"
      echo "The supported boards are:"
      for supported_board in "${supported_boards[@]}"; do
        echo "- ${supported_board}"
      done
      exit 1
    fi
    ;;

  r)
    revision=${OPTARG}
    ;;

  d)
    device=${OPTARG}
    ;;

  l)
    l4t=${OPTARG}
    if [[ "$l4t" != 32 && "$l4t" != 35 && "$l4t" != 36 ]]; then
      printf "\e[31mError: Unsupported l4t value: %s \n\e[0m" "$l4t"
      echo "The possible values are: 32, 35, 36."
      exit 1
    fi
    ;;

  h)
    usage
    ;;

  *) usage ;;
  esac
done

if [ "$board" = "" ]; then
  printf "\e[31mError: board argument in required.\e[0m \n\n"
  usage
fi

case $board in
"jetson-nano")
  if [[ "$revision" != "100" && "$revision" != "200" && "$revision" != "300" ]]; then
    printf "\e[31mError: Unknown revision for Jetson nano board.\n\e[0m"
    echo "Supported revision: 100, 200 or 300"
    exit 1
  fi
  ;;

"jetson-orin-nano" | "jetson-xavier-nx" | "jetson-agx-xavier")

  if [ "$device" = "" ]; then
    printf "\e[31mError: device argument required.\n\e[0m"
    usage
  fi

  if [[ "$device" != "SD" && "$device" != "USB" ]]; then
    printf "\e[31mError: Unknown device.\n\e[0m"
    echo "device must be SD or USB"
    exit 1
  fi
  ;;

*) ;;
esac

case $board in
"jetson-nano" | "jetson-nano-2gb")
  l4t=32
  ;;

"jetson-agx-xavier" | "jetson-xavier-nx")
  if [[ "$l4t" == "" ]]; then
    echo "Error: l4t version not provided."
    echo "l4t must be 32 or 35"
    exit 1
  fi
  if [[ "$l4t" != 32 && "$l4t" != 35 ]]; then
    echo "The $board only supports 32.x or 35.x versions."
    exit 1
  fi
  ;;

"jetson-orin-nano")
  if [[ "$l4t" == "" ]]; then
    echo "Error: l4t version not provided."
    echo "l4t must be 35 or 36"
    exit 1
  fi

  if [[ "$l4t" != 35 && "$l4t" != 36 ]]; then
    echo "The $board only supports 35.x or 36.x versions."
    exit 1
  fi

  ;;
*) ;;
esac

sudo -E XDG_RUNTIME_DIR= DBUS_SESSION_BUS_ADDRESS= podman build \
  --cap-add=all \
  --jobs=4 \
  -f Containerfile.image.l4t"$l4t" \
  -t jetson-build-image-l4t"$l4t"

sudo podman run \
  --rm \
  --privileged \
  -v .:/jetson \
  -e JETSON_BOARD="$board" \
  -e JETSON_DEVICE="$device" \
  -e JETSON_REVISION="$revision" \
  localhost/jetson-build-image-l4t"$l4t":latest \
  create-jetson-image.sh
