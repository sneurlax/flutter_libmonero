#!/bin/bash

LIB_ROOT=../..
OS=android
ANDROID_LIBS_DIR=$LIB_ROOT/$OS/src/main/jniLibs

TAG_COMMIT=$(git log -1 --pretty=format:"%H")

rm -rf flutter_libmonero_bins
git clone https://git.cypherstack.com/stackwallet/flutter_libmonero_bins
if [ -d flutter_libmonero_bins ]; then
  cd flutter_libmonero_bins
else
  echo "Failed to clone flutter_libmonero_bins"
  exit 1
fi

MONERO_BIN=libcw_monero.so
WOWNERO_BIN=libcw_wownero.so

for TARGET in arm64-v8a armeabi-v7a x86_64
do
  ARCH_PATH=$TARGET/release
  if [ $(git tag -l $TARGET"_$TAG_COMMIT") ]; then
    git checkout $TARGET"_$TAG_COMMIT"
    mkdir -p ../$LINUX_LIBS_DIR/$ARCH_PATH
    if [ -f "$OS/$ARCH_PATH/$MONERO_BIN" ]; then
      # TODO verify bin checksum hashes
      cp -rf "$OS/$ARCH_PATH/$MONERO_BIN" ../build/
    else
      echo "$TARGET $MONERO_BIN not found!"
    fi
    if [ -f "$OS/$ARCH_PATH/$WOWNERO_BIN" ]; then
      # TODO verify bin checksum hashes
      cp -rf "$OS/$ARCH_PATH/$WOWNERO_BIN" ../build/
    else
      echo "$TARGET $WOWNERO_BIN not found!"
    fi
  else
    echo "No precompiled bins for $TARGET found!"
  fi
done
