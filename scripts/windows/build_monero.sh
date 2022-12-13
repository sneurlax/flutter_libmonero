#!/bin/bash

. ./config.sh

MONERO_SRC_DIR=${WORKDIR}/monero
cd $MONERO_SRC_DIR
mkdir -p build
cd build

BUILD_64=ON
TAG="win-x64"
ARCH="x86-64"

x86_64-w64-mingw32.static-cmake \
	-DCMAKE_TOOLCHAIN_FILE=${MONERO_SRC_DIR}/contrib/depends/x86_64-w64-mingw32/share/toolchain.cmake \
	-DCMAKE_FIND_DEBUG_MODE=On \
	-DCMAKE_CXX_FLAGS="-fPIC" \
	-D USE_DEVICE_TREZOR=OFF \
	-D BUILD_GUI_DEPS=1 \
	-D BUILD_TESTS=OFF \
	-D ARCH=${ARCH} \
	-D BUILD_64=${BUILD_64} \
	-D CMAKE_BUILD_TYPE=release \
	-D BUILD_TAG=${TAG} \
	$FLAGS ..

make wallet_api -j$THREADS
