FROM multiarch/ubuntu-core:arm64-bionic
RUN apt update && apt install -y debootstrap build-essential fakechroot fakeroot python3-pip python3-setuptools coreutils parted wget gdisk e2fsprogs lbzip2 sudo cmake
RUN pip3 install ansible
RUN mkdir -p /build/rootfs
VOLUME /build
WORKDIR /build
ENV JETSON_ROOTFS_DIR=/build/rootfs
ENV JETSON_BUILD_DIR=/build

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]

