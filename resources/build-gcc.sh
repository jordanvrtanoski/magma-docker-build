#! /bin/bash

GCC_VERSION="7.5.0"
WORKDIR="$HOME/src/"
INSTALLDIR="/usr"

apt-get -y install gcc wget bzip2 make build-essential

# get the source code
cd $WORKDIR
wget http://www.netgull.com/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar -xf gcc-${GCC_VERSION}.tar.gz

# download the prerequisites
cd gcc-${GCC_VERSION}
./contrib/download_prerequisites

# create the build directory
cd ..
mkdir gcc-build
cd gcc-build

# build
../gcc-${GCC_VERSION}/configure                      \
    --prefix=${INSTALLDIR}                           \
    --enable-shared                                  \
    --enable-threads=posix                           \
    --enable-__cxa_atexit                            \
    --enable-clocale=gnu                             \
    --enable-languages=c,c++                         \
&& make -j $(nproc) \
&& make install
