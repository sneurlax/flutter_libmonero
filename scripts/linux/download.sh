#!/bin/bash

. ./config.sh

OS=linux
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
TARGET=$TYPES_OF_BUILD
ARCH_PATH=$TARGET

if [ $(git tag -l "${OS}_${TARGET}_${TAG_COMMIT}") ]; then
    git checkout "${OS}_${TARGET}_${TAG_COMMIT}"
    mkdir -p ../build
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
