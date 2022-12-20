#!/bin/sh

set -e

. ./config.sh

OPENSSL_VERSION=1.1.1q
OPENSSL_SHA256="d7939ce614029cdff0b6c20f0e2e5703158a489a72b2507b8bd51bf8c8fd10ca"
OPENSSL_FILENAME=openssl-$OPENSSL_VERSION.tar.gz
OPENSSL_SRC_DIR=$WORKDIR/openssl-$OPENSSL_VERSION
OPENSSL_FILE_PATH=$CACHEDIR/$OPENSSL_FILENAME

if [ ! -e "$OPENSSL_FILE_PATH" ]; then
  curl https://www.openssl.org/source/$OPENSSL_FILENAME -o $OPENSSL_FILE_PATH
fi

echo $OPENSSL_SHA256 $OPENSSL_FILE_PATH | sha256sum -c - || exit 1

cd $WORKDIR
rm -rf $OPENSSL_SRC_DIR
tar -xzf $OPENSSL_FILE_PATH -C $WORKDIR
cd $OPENSSL_SRC_DIR

#sed -i -e "s/mandroid/target\ ${TARGET}\-linux\-android/" Configure
CC=gcc
./Configure mingw64 \
	no-shared \
	no-tests \
	--cross-compile-prefix=x86_64-w64-mingw32.static- \
	--with-zlib-include=${PREFIX}/include \
	--with-zlib-lib=${PREFIX}/lib \
	--prefix=${WORKDIR}/openssl \
	--openssldir=${WORKDIR}/openssl \
	OPENSSL_LIBS="-lcrypt32 -lgdi32 -lwsock32 -lws2_32"
make -j$THREADS
make -j$THREADS install_sw
