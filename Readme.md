# Nvidia Jetson Minimalist Images

## Motivation

The need for the minimalist images came from the official jetson images being large in size and containing pre-installed packages that are not necessary, resulting in the consumption of valuable disk space and memory.

## Supported boards

- [x] Jetson nano
- [x] Jetson nano 2gb
- [x] Jetson orin nano
- [x] Jetso agx xavier
- [x] Jetson xavier nx

## Spec

**Supported OS**: ubuntu 20.04 & 22.04

**L4T versions**: 32.x, 35.x, 36.x

> [!IMPORTANT]
> For jetson orin nano, you might need to update the firmware before being able to use an image based on l4t 36.x
>
> check this [link](https://www.jetson-ai-lab.com/initial_setup_jon.html) for more information.

## Download the prebuilt images

The prebuilt images are available in the GitHub release page 👉 [here](https://github.com/pythops/jetson-image/releases)

To be able to decompress the images, you must have [lrzip](https://github.com/ckolivas/lrzip) installed.

After the image is decompressed, follow the section below to flash the image to your board.

The default login is:

```
username: jetson
password: jetson
```

## Build the jetson image yourself

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

For ubuntu 20.04

```
just build-jetson-rootfs 20.04
```

For ubuntu 22.04

```
just build-jetson-rootfs 22.04
```

This will create the rootfs in the `rootfs` directory.

> [!TIP]
> You can modify the `Containerfile.rootfs.*` files to add any tool or configuration that you will need in the final image.

Next, use the following command to build the Jetson image:

```
$ just build-jetson-image -b <board> -r <revision> -d <device>
```

For example, to build an image for `jetson-orin-nano` board:

```bash
$ just build-jetson-image -b jetson-orin-nano -d SD
```

Run with `-h` for more information

```bash
just build-jetson-image -h
```

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

For the jetson nano for instance with the new image, only 150MB of RAM is used, which leaves you with 3.85 GB for your projects !

If you find this helpful, don't forget to give it a star ⭐

## Looking for professional support ?

If you need more advanced configuration or a custom setup, you can contact me on this address support@pythops.com

## License

AGPLv3
