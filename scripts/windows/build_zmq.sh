#!/bin/sh

. ./config.sh

ZMQ_BRANCH=v4.3.3
ZMQ_COMMIT_HASH="04f5bbedee58c538934374dc45182d8fc5926fa3"
ZMQ_SRC_DIR=$WORKDIR/libzmq

cd $WORKDIR
rm -rf $ZMQ_SRC_DIR
git clone https://github.com/zeromq/libzmq.git ${ZMQ_SRC_DIR} -b ${ZMQ_BRANCH}
cd $ZMQ_SRC_DIR
git checkout ${ZMQ_COMMIT_HASH}

CC=x86_64-w64-mingw32.static-gcc
CXX=x86_64-w64-mingw32.static-g++
HOST=x86_64-w64-mingw32
./autogen.sh
./configure \
	--without-documentation \
	--without-docs \
	--disable-shared \
	#--disable-curve \
	--prefix=${PREFIX} \
	--host=${HOST} \
	--enable-static \
	--with-pic #\
	#CFLAGS="-Wall -Wno-pedantic-ms-format -DLIBCZMQ_EXPORTS -DZMQ_DEFINED_STDINT"
make -j$THREADS
make install

# See http://vrecan.github.io/post/crosscompile_go_zeromq/
# See https://stackoverflow.com/questions/21322707/zlib-header-not-found-when-cross-compiling-with-mingw