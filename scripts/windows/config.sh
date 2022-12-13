#!/bin/sh

export API=21
export SCRIPTDIR="$(pwd)"
export WORKDIR=${SCRIPTDIR}/build
export CACHEDIR=${SCRIPTDIR}/cache
export ANDROID_NDK_ZIP=${WORKDIR}/android-ndk-r17c.zip
export ANDROID_NDK_ROOT=${WORKDIR}/android-ndk-r17c
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export TOOLCHAIN_DIR="${WORKDIR}/toolchain"
export TOOLCHAIN_BASE_DIR=$TOOLCHAIN_DIR
export ORIGINAL_PATH=$PATH
export THREADS=$(nproc)
export TYPES_OF_BUILD="x86_64"

if [ -z "$IS_ARM" ]; then
  export TYPES_OF_BUILD="x86_64"
else
  export TYPES_OF_BUILD="aarch64"
fi
export PREFIX=$WORKDIR/prefix_${TYPES_OF_BUILD}

export CC=x86_64-w64-mingw32.static-gcc
export CXX=x86_64-w64-mingw32.static-g++
export HOST=x86_64-w64-mingw32
export CROSS_COMPILE=x86_64-w64-mingw32.static-
export CROSS=x86_64-w64-mingw32.static-
