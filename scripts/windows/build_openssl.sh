#!/bin/sh

set -e

. ./config.sh

OPENSSL_FILENAME=openssl-1.1.1q.tar.gz
OPENSSL_FILE_PATH=$WORKDIR/$OPENSSL_FILENAME
OPENSSL_SRC_DIR=$WORKDIR/openssl-1.1.1q
OPENSSL_SHA256="d7939ce614029cdff0b6c20f0e2e5703158a489a72b2507b8bd51bf8c8fd10ca"

if [ ! -e "$OPENSSL_FILE_PATH" ]; then
  curl https://www.openssl.org/source/$OPENSSL_FILENAME -o $OPENSSL_FILE_PATH
fi

echo $OPENSSL_SHA256 $OPENSSL_FILE_PATH | sha256sum -c - || exit 1

cd $WORKDIR
rm -rf $OPENSSL_SRC_DIR
tar -xzf $OPENSSL_FILE_PATH -C $WORKDIR
cd $OPENSSL_SRC_DIR

#sed -i -e "s/mandroid/target\ ${TARGET}\-linux\-android/" Configure
./Configure ${X_ARCH} \
	no-shared no-tests \
	--with-zlib-include=${PREFIX}/include \
	--with-zlib-lib=${PREFIX}/lib \
	--prefix=${PREFIX} \
	--openssldir=${PREFIX}
make -j$THREADS
make -j$THREADS install_sw
