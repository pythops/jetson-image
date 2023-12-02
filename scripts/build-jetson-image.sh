#!/usr/bin/env bash

# Author Badr @pythops

set -e

supported_boards=("jetson-nano" "jetson-nano-2gb" "jetson-orin-nano" "jetson-agx-xavier" "jetson-xavier-nx")

function usage() {
    echo "Usage: $0 -b <board> -r <revision> -d <device>"
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
    exit 1
}

while getopts b:r:d:h opts; do
    case "${opts}" in

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

    h)
        usage
        ;;

    *) usage ;;
    esac
done

if [ -z "$board" ]; then
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

    if [ -z "$device" ]; then
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

# Build the image where the jetson image will be built
if [ "$board" == "jetson-nano" ] || [ "$board" == "jetson-nano-2gb" ]; then
    sudo -E XDG_RUNTIME_DIR= podman build \
        --cap-add=all \
        --jobs=4 \
        -f Containerfile.image.l4t32 \
        -t jetson-build-image-l4t32
else
    sudo -E XDG_RUNTIME_DIR= podman build \
        --cap-add=all \
        --jobs=4 \
        -f Containerfile.image.l4t35 \
        -t jetson-build-image-l4t35
fi

# Build the jetson image
if [ "$board" == "jetson-nano" ]; then
    sudo podman run \
        --rm \
        --privileged \
        -v .:/jetson \
        -e JETSON_BOARD="jetson-nano" \
        -e JETSON_REVISION="$revision" \
        localhost/jetson-build-image-l4t32:latest \
        create-jetson-image.sh

elif [ "$board" == "jetson-nano-2gb" ]; then
    sudo podman run \
        --rm \
        --privileged \
        -v .:/jetson \
        -e JETSON_BOARD="jetson-nano-2gb" \
        localhost/jetson-build-image-l4t32:latest \
        create-jetson-image.sh

else
    sudo podman run \
        --rm \
        --cap-add=all \
        --privileged \
        -v .:/jetson \
        -e JETSON_BOARD="$board" \
        -e JETSON_DEVICE="$device" \
        localhost/jetson-build-image-l4t35:latest \
        create-jetson-image.sh

fi
