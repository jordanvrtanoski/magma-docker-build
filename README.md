# Magma Build system in a Docker container

## TL;DR
This repository provides the patches and the required Docker files to allow building Magma inside a Docker container.
The build system provides processes for both X86 and ARM64 releases.

To start the build, you need a Docker environment. Clone the repo and start the build.

To build for ARM64 on X86 you need to enable the emulated containers. In case you do this on MacOS, 
the Docker environment is already prepared for the emulation. If not, you need to 
follow [instructions](https://github.com/jordanvrtanoski/magma-docker-build.git) how to set-up your environment

It is important to start the build from the root of the project.

```
$ git clone https://github.com/jordanvrtanoski/magma-docker-build.git
$ cd magma-docker-build
$ ./build.sh
```

> Warning: The project is in early stage. Test the resulting packages before using them in production environments

## Project structure

Following are the main components of the project:

1. Docker files - recipes to build the containers. The files are separeded by architecture;
1. The patches required to build a release;
1. Helper scripts and;
1. Documents

The files are organizes in the following project tree:

```
root				: README.md and the main build script
  |- doc			: Documensts related to the project
  |- arm64			: Docker files for ARM64 build
  |- amd64			: Docker files for X86 build
  |- resources		: Resources used for the build (patches, certificates, config files, etc.)
  |- packages		: Distribution packages
      |- arm64		: Distribution packages for ARM64
      |- amd64		: Distribution package for X86
```

## Setup the aarch64 emulation for Linux

In order to allow Docker to emulate the ARM64 (aarch64), you will need to install QEMU and set-up the `binfmt_misc` magic numbers. The `binfmt_misc` is a kernel function that allows execution of arbitrary binary formats. This can be used to inform the kernel to use QUEMU when there is binary that is complied for aarch64. If you want more information about the whole process, visit the [quemu-user-static](https://github.com/multiarch/qemu-user-static) repository where you can find more details about the whole process.

To set it up quickly (on Ubuntu) use the following recipe:

```
sudo apt-get install qemu binfmt-support qemu-user-static # Install the qemu packages
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

docker run --rm -t arm64v8/ubuntu uname -m # Testing the emulation environment
#aarch64
```

> Note: The emulated container will report the kernel version in a "confusing" way. The kernel version will be 
> reported from the X86 kernel running on the Docker host, while the architecture will be reported as aarch64. 
> If the build process tries to read the kernel release (`uname -r`) than the build process might fail 
> or generate wrong binaries. 
> 
> Following is example of the `uname -a` output from a docker container emulated
>
>```
$ docker run -ti --rm arm64v8/debian:9.11 /bin/bash
root@50a1e53658a8:/# uname -a
Linux 50a1e53658a8 4.19.121-linuxkit #1 SMP Tue Dec 1 17:50:32 UTC 2020 aarch64 GNU/Linux
>```


## Contributing

All contributions to the project are wellcomed. Read [contributing](doc/CONTRIBUTING.md) instructions before you start.

