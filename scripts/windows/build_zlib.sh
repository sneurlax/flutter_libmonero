#!/bin/sh

set -e

. ./config.sh

ZLIB_TAG=v1.2.11
ZLIB_COMMIT_HASH="cacf7f1d4e3d44d871b605da3b647f07d718623f"
ZLIB_DIR=$WORKDIR/zlib

rm -rf $ZLIB_DIR
git clone -b $ZLIB_TAG --depth 1 https://github.com/madler/zlib $ZLIB_DIR
cd $ZLIB_DIR
git reset --hard $ZLIB_COMMIT_HASH

sed 's/PREFIX =/PREFIX = x86_64-w64-mingw32.static-/' -i win32/Makefile.gcc

HOST=x86_64-w64-mingw32
CC=x86_64-w64-mingw32.static-gcc
CXX=x86_64-w64-mingw32.static-g++
: '
./configure \
	--static \
	--prefix=${PREFIX}
make
make install
'
make -f win32/Makefile.gcc
	DESTDIR=${PREFIX} \
	BINARY_PATH=/usr/x86_64-w64-mingw32/bin \
	INCLUDE_PATH=/usr/x86_64-w64-mingw32/include \
	LIBRARY_PATH=/usr/x86_64-w64-mingw32/lib \
	PREFIX=x86_64-w64-mingw32.static- \
	make -f win32/Makefile.gcc install # See https://stackoverflow.com/a/26021820
cp -r ${PREFIX}/usr/x86_64-w64-mingw32/* ${PREFIX}
rm -rf ${PREFIX}/usr # 👻

# See https://stackoverflow.com/questions/21322707/zlib-header-not-found-when-cross-compiling-with-mingw