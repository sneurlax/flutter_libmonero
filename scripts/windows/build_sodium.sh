#!/bin/sh

. ./config.sh

SODIUM_BRANCH=1.0.16
SODIUM_SRC_DIR=${WORKDIR}/libsodium

cd $WORKDIR
rm -rf $SODIUM_SRC_DIR
git clone https://github.com/jedisct1/libsodium.git $SODIUM_SRC_DIR -b $SODIUM_BRANCH
cd $SODIUM_SRC_DIR

./autogen.sh
./configure \
	--prefix=${PREFIX} \
	--host=${HOST} \
	--enable-static \
	--disable-shared
make -j$THREADS
make install
