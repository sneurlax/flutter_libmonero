#!/bin/bash

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

buildmoneroarch () {
  local arch=$1
  FLAGS=""
  PREFIX=${WORKDIR}/prefix_${arch}
  DEST_LIB_DIR=${PREFIX}/lib/monero
  DEST_INCLUDE_DIR=${PREFIX}/include/monero
  export CMAKE_INCLUDE_PATH="${PREFIX}/include"
  export CMAKE_LIBRARY_PATH="${PREFIX}/lib"
  ANDROID_STANDALONE_TOOLCHAIN_PATH="${TOOLCHAIN_BASE_DIR}_${arch}"
  PATH="${ANDROID_STANDALONE_TOOLCHAIN_PATH}/bin:${ORIGINAL_PATH}"

  mkdir -p $DEST_LIB_DIR
  mkdir -p $DEST_INCLUDE_DIR

  case $arch in
    "aarch"	)
      CLANG=arm-linux-androideabi-clang
      CXXLANG=arm-linux-androideabi-clang++
      BUILD_64=OFF
      TAG="android-armv7"
      ARCH="armv7-a"
      ARCH_ABI="armeabi-v7a"
      FLAGS="-D CMAKE_ANDROID_ARM_MODE=ON -D NO_AES=true";;
    "aarch64"	)
      CLANG=aarch64-linux-androideabi-clang
      CXXLANG=aarch64-linux-androideabi-clang++
      BUILD_64=ON
      TAG="android-armv8"
      ARCH="armv8-a"
      ARCH_ABI="arm64-v8a";;
    "i686"		)
      CLANG=i686-linux-androideabi-clang
      CXXLANG=i686-linux-androideabi-clang++
      BUILD_64=OFF
      TAG="android-x86"
      ARCH="i686"
      ARCH_ABI="x86";;
    "x86_64"	)
      CLANG=x86_64-linux-androideabi-clang
      CXXLANG=x86_64-linux-androideabi-clang++
      BUILD_64=ON
      TAG="android-x86_64"
      ARCH="x86-64"
      ARCH_ABI="x86_64";;
  esac

  cd $MONERO_SRC_DIR
  rm -rf ./build/release_"${arch}"
  mkdir -p ./build/release_"${arch}"
  cd ./build/release_"${arch}"
  CC=${CLANG} CXX=${CXXLANG} cmake -DCMAKE_ANDROID_NDK="${ANDROID_NDK_HOME}" -DANDROID_PLATFORM="android-${API}" -DCMAKE_SYSTEM_VERSION="${API}" -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH=${ARCH} -D STATIC=ON -D BUILD_64=${BUILD_64} -D CMAKE_BUILD_TYPE=release -D ANDROID=true -D INSTALL_VENDORED_LIBUNBOUND=ON -D BUILD_TAG=${TAG} -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_STANDALONE_TOOLCHAIN="${ANDROID_STANDALONE_TOOLCHAIN_PATH}" -D CMAKE_ANDROID_ARCH_ABI=${ARCH_ABI} $FLAGS ../..

  make wallet_api -j$THREADS
  find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \;

  cp -r ./lib/* $DEST_LIB_DIR
  cp ../../src/wallet/api/wallet2_api.h  $DEST_INCLUDE_DIR
}

for arch in "aarch" "aarch64" "i686" "x86_64"
do
  buildmoneroarch "$arch"
done
wait
