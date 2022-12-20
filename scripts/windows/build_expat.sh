#!/bin/bash

. ./config.sh

EXPAT_VERSION=R_2_4_8
EXPAT_HASH="3bab6c09bbe8bf42d84b81563ddbcf4cca4be838"
EXPAT_SRC_DIR=$WORKDIR/libexpat

cd $WORKDIR
rm -rf $EXPAT_SRC_DIR
git clone https://github.com/libexpat/libexpat.git -b ${EXPAT_VERSION} ${EXPAT_SRC_DIR}
cd $EXPAT_SRC_DIR
test `git rev-parse HEAD` = ${EXPAT_HASH} || exit 1
cd $EXPAT_SRC_DIR/expat

./buildconf.sh
#CC=clang CXX=clang++
CC=x86_64-w64-mingw32.static-gcc
./configure \
	CFLAGS=-fPIC \
	CXXFLAGS=-fPIC \
	--enable-static \
	--disable-shared \
	--prefix=${PREFIX} \
	--host=${HOST}
make -j$THREADS
make -j$THREADS install
