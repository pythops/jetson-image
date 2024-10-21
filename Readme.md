# Nvidia Jetson Minimalist Images

[![Discord][discord-badge]][chat-url]

[discord-badge]: https://img.shields.io/badge/Discord-chat-5865F2?style=for-the-badge&logo=discord
[chat-url]: https://discord.gg/wA7Pg9H6

## Motivation

The need for the minimalist images came from the official jetson images being large in size and containing pre-installed packages that are not necessary, resulting in the consumption of valuable disk space and memory.

## Supported boards

- [x] Jetson nano
- [x] Jetson nano 2gb
- [x] Jetson orin nano
- [x] Jetso agx xavier
- [x] Jetson xavier nx

## Spec

**Supported Ubuntu releases**: 20.04, 22.04, 24.04

**L4T versions**: 32.x, 35.x, 36.x

> [!IMPORTANT]
> For jetson orin nano, you might need to update the firmware before being able to use an image based on l4t 36.x
>
> check this [link](https://www.jetson-ai-lab.com/initial_setup_jon.html) for more information.

## Build the jetson image

> [!NOTE]
> Building the jetson image has been tested only on Linux machines.

Building the jetson image is fairly easy. All you need to have is the following tools installed on your machine.

- [podman](https://github.com/containers/podman)
- [just](https://github.com/casey/just)
- [jq](https://github.com/stedolan/jq)
- [qemu-user-static]()

Start by cloning the repo from github

```bash
git clone https://github.com/pythops/jetson-image
cd jetson-image
```

Then create a new rootfs with the desired ubuntu version.

> [!NOTE]
> Only the orin family boards can use ubuntu 24.04

For ubuntu 24.04

```
just build-jetson-rootfs 24.04
```

This will create the rootfs in the `rootfs` directory.

> [!TIP]
> You can modify the `Containerfile.rootfs.*` files to add any tool or configuration that you will need in the final image.

Next, use the following command to build the Jetson image:

```
$ just build-jetson-image -b <board> -r <revision> -d <device> -l <l4t version>
```

> [!TIP]
> If you wish to add some specific nvidia packages that are present in the `common` section from [this link](https://repo.download.nvidia.com/jetson/)
> such as `libcudnn8` for instance, then edit the file`l4t_packages.txt` in the root directory, add list each package name on separate line.

For example, to build an image for `jetson-orin-nano` board:

```bash
$ just build-jetson-image -b jetson-orin-nano -d SD -l 36
```

Run with `-h` for more information

```bash
just build-jetson-image -h
```

> [!NOTE]
> Not every jetson board can be updated to the latest l4t version.
>
> Check this [link](https://developer.nvidia.com/embedded/jetson-linux-archive) for more information.

The Jetson image will be built and saved in the current directory in a file named `jetson.img`

## Flashing the image into your board

To flash the jetson image, just run the following command:

```
$ sudo just flash-jetson-image <jetson image file> <device>
```

Where `device` is the name of the sdcard/usb identified by your system.
For instance, if your sdard is recognized as `/dev/sda`, then replace `device` by `/dev/sda`

> [!NOTE]
> There are numerous tools out there to flash images to sd card that you can use. I stick with `dd` as it's simple and does the job.

## Nvidia Libraries

Once you boot the board with the new image, then you can install Nvidia libraries using `apt`

```bash
$ sudo apt install -y libcudnn8 libcudnn8-dev ...
```

## Result

For the `jetson orin nano` for instance with the new image, only 220MB of RAM is used, which leaves plenty of RAM for your projects !

![](https://github.com/user-attachments/assets/7404e20f-3ccd-42c7-b8d6-e93c635aa6f0)

## Looking for professional support ?

If you need more advanced configuration or a custom setup, you can contact me on this address support@pythops.com

## License

AGPLv3
