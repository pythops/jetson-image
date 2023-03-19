default:
    @just --list

build-jetson-rootfs:
    @scripts/build-base-rootfs.sh

build-jetson-image board revision="300":
    #!/usr/bin/env bash

    if [ {{ board }} != "jetson-nano" ] && [ {{ board }} != "jetson-nano-2gb" ]; then
        echo "Unsupported board {{ board }}"
        echo "The only supported boards are:"
        echo "- jetson-nano"
        echo "- jetson-nano-2gb"
        exit
    fi

    if [ {{ board }} == "jetson-nano" ]; then
        if [ "{{ revision }}" != "300" ] && [ "{{ revision }}" != "200" ]; then
            echo "Unknown revision for Jetson nano board"
            echo "Supported revision: 200 or 300"
            exit
        fi
        echo "Building for Jetson nano board "
        scripts/build-jetson-image.sh {{ board }} {{ revision }}
    else
        echo "Building for jetson-nano-2gb board"
        scripts/build-jetson-image.sh {{ board }}
    fi
