# Nvidia Jetson Minimalist Images

[![Discord][discord-badge]][chat-url]

[discord-badge]: https://img.shields.io/badge/Discord-chat-5865F2?style=for-the-badge&logo=discord
[chat-url]: https://discord.gg/mfSRc9Jann

## Motivation

The need for the minimalist images came from the official jetson images being large in size and containing pre-installed packages that are not necessary, resulting in the consumption of valuable disk space and memory.

## Supported boards

- [x] Jetson nano
- [x] Jetson nano 2gb
- [x] Jetson orin nano
- [x] Jetson agx orin
- [x] Jetso agx xavier
- [x] Jetson xavier nx

## Spec

**Supported Ubuntu releases**: 20.04, 22.04, 24.04

**L4T versions**: 32.x, 35.x, 36.x

## Build the jetson image

> [!NOTE]
> Building the jetson image has been tested only on Linux machines.

Building the jetson image is fairly easy. All you need to have is the following tools installed on your machine.

- [podman](https://github.com/containers/podman)
- [just](https://github.com/casey/just)
- [jq](https://github.com/stedolan/jq)
- [qemu-user-static](https://github.com/multiarch/qemu-user-static)

Start by cloning the repo from github

```bash
git clone https://github.com/pythops/jetson-image
cd jetson-image
```

<br>

### I. Create a new rootfs

##### 1. WiFi configuration (Optional)

The Wi-Fi configuration must be set up before running the build command so it can be properly baked into the image.

Creates a file named `<network_name>.psk` in the `config/iwd/networks` directory with the following content

```
[Security]
Passphrase=<WiFI Password>

[Settings]
AutoConnect=true
```

##### 2. Build the rootfs

> [!NOTE]
> Only the orin family boards can use ubuntu 24.04

Run the following command

```
just build-jetson-rootfs <ubuntu_version>
```

This will create the rootfs in the `rootfs` directory.

`ubuntu_version` can take on these values: `20.04`, `22.04`, `24.04`

for example, to build roorfs based on `24.04`:

```
just build-jetson-rootfs 24.04
```

> [!NOTE]
> You can modify the `Containerfile.rootfs.*` files to add any tool or configuration that you will need in the final image.

<br>

### II. Build the Jetson image:

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

<br>

## III. Flashing the image into your board

To flash the jetson image, just run the following command:

```
$ sudo just flash-jetson-image <jetson image file> <device>
```

Where `device` is the name of the sdcard/usb identified by your system.
For instance, if your sdard is recognized as `/dev/sda`, then replace `device` by `/dev/sda`

> [!NOTE]
> There are numerous tools out there to flash images to sd card that you can use. I stick with `dd` as it's simple and does the job.

<br>

## IV. Boot the board

#### Login

Once you boot the board, you can login with:

```
username: jetson
password: jetson
```

> [!NOTE]
> ssh server is running by default and listen on the port 22

#### Nvidia Libraries

Nvidia libraries can be installed using `apt`

```bash
$ sudo apt install -y libcudnn8 libcudnn8-dev ...
```

#### New tools

[impala](https://github.com/pythops/impala): A TUI for managing WiFi.

[tegratop](https://github.com/pythops/tegratop): A Comprehensive TUI monitoring tool for Nvidia jetson boards.

<br>

## Result

For the `jetson orin nano` for instance with the new image, only 220MB of RAM is used, which leaves plenty of RAM for your projects !

![](https://github.com/user-attachments/assets/7404e20f-3ccd-42c7-b8d6-e93c635aa6f0)

## License

AGPLv3
