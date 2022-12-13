#!/bin/bash

. ./config.sh
: '
UNBOUND_VERSION=release-1.15.0
UNBOUND_HASH="c29b0e0a96c4d281aef40d69a11c564d6ed1a2c6"
UNBOUND_SRC_DIR=$WORKDIR/unbound-1.15.0

UNBOUND_VERSION=release-1.16.2
UNBOUND_HASH="cbed768b8ff9bfcf11089a5f1699b7e5707f1ea5"
UNBOUND_SRC_DIR=$WORKDIR/unbound-1.16.2

UNBOUND_VERSION=release-1.17.0
UNBOUND_HASH="d25e0cd9b0545ff13120430c94326ceaf14b074f"
UNBOUND_SRC_DIR=$WORKDIR/unbound-1.17.0
'
UNBOUND_VERSION=fix/1.17.0
UNBOUND_HASH="0b5dd63b7417601448acc2e2b9ff2d8dd07ad31f"
UNBOUND_SRC_DIR=$WORKDIR/unbound-1.17.0

cd $WORKDIR
rm -rf $UNBOUND_SRC_DIR
git clone https://github.com/cypherstack/unbound.git -b ${UNBOUND_VERSION} ${UNBOUND_SRC_DIR} # See https://github.com/NLnetLabs/unbound/pull/808; once merged, use NLNetLabs/unbound instead of cypherstack/unbound#fix/windows
cd $UNBOUND_SRC_DIR
test `git rev-parse HEAD` = ${UNBOUND_HASH} || exit 1

./configure \
	CFLAGS=-fPIC \
	CXXFLAGS=-fPIC \
	--prefix=${PREFIX} \
	--host=${HOST} \
	--target=${HOST} \
	--enable-static \
	--disable-shared \
	--disable-flto \
	--with-pic \
	--with-ssl=${PREFIX} \
	--with-libexpat=${PREFIX} \
	LDFLAGS="-lws2_32 -liphlpapi -lrpcrt4" 
make CROSS=x86_64-w64-mingw32.static- -j$THREADS
make install
