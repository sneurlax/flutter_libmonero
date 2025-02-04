#!/bin/sh

. ./config.sh
MONERO_URL="https://github.com/monero-project/monero.git"
MONERO_VERSION=v0.18.2.2
MONERO_SHA_HEAD=e06129bb4d1076f4f2cebabddcee09f1e9e30dcc
MONERO_SRC_DIR=${WORKDIR}/monero
MONERO_BRANCH=main

git clone ${MONERO_URL} ${MONERO_SRC_DIR} --branch ${MONERO_VERSION}
cd $MONERO_SRC_DIR
git reset --hard $MONERO_SHA_HEAD
git submodule init
git submodule update

for arch in $TYPES_OF_BUILD
do
FLAGS=""
PREFIX=${WORKDIR}/prefix_${arch}
DEST_LIB_DIR=${PREFIX}/lib/monero
DEST_INCLUDE_DIR=${PREFIX}/include/monero
export CMAKE_INCLUDE_PATH="${PREFIX}/include"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR
LIBUNBOUND_PATH=${PREFIX}/lib/libunbound.a
if [ -f "$LIBUNBOUND_PATH" ]; then
  cp $LIBUNBOUND_PATH $DEST_LIB_DIR
fi

case $arch in
	"x86_64"	)
		BUILD_64=ON
		TAG="linux-x86_64"
		ARCH="x86-64"
		ARCH_ABI="x86_64";;
	"aarch64"	)
		BUILD_64=ON
		TAG="linux-aarch64"
		ARCH="aarch64"
		ARCH_ABI="aarch64";;
esac

cd $MONERO_SRC_DIR
rm -rf ./build/release
mkdir -p ./build/release
cd ./build/release

CW_DIR="$(pwd)"/../../../../../../../flutter_libmonero
CW_MONERO_EXTERNAL_DIR=${CW_DIR}/cw_monero/ios/External/android
mkdir -p $CW_MONERO_EXTERNAL_DIR/include
cp ../../src/wallet/api/wallet2_api.h $DEST_INCLUDE_DIR
cp ../../src/wallet/api/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include

cmake -DCMAKE_CXX_FLAGS="-fPIC" -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH=${ARCH} -D BUILD_64=${BUILD_64} -D CMAKE_BUILD_TYPE=release -D INSTALL_VENDORED_LIBUNBOUND=ON -D BUILD_TAG=${TAG} $FLAGS ../..
    
make wallet_api -j$THREADS
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \;

cp -r ./lib/* $DEST_LIB_DIR
done
