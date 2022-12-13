#!/bin/bash

. ./config.sh

MONERO_BRANCH=v0.18.1.2
MONERO_SRC_DIR=${WORKDIR}/monero

git clone https://github.com/monero-project/monero.git ${MONERO_SRC_DIR} --branch ${MONERO_BRANCH}
cd $MONERO_SRC_DIR
git submodule init
git submodule update

sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix

cd contrib/depends
make HOST=x86_64-w64-mingw32 -j$THREADS
