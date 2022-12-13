#!/bin/sh

. ./config.sh
BOOST_SRC_DIR=$WORKDIR/boost_1_78_0
BOOST_FILENAME=boost_1_78_0.tar.bz2
BOOST_VERSION=1.78.0

BOOST_FILE_PATH=$WORKDIR/$BOOST_FILENAME
BOOST_SHA256="8681f175d4bdb26c52222665793eef08490d7758529330f98d3b29dd0735bccc"

if [ ! -e "$BOOST_FILE_PATH" ]; then
	curl -L http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/${BOOST_FILENAME} > $BOOST_FILE_PATH
fi

echo $BOOST_SHA256 $BOOST_FILE_PATH | sha256sum -c - || exit 1

cd $WORKDIR
rm -rf $BOOST_SRC_DIR
rm -rf $PREFIX/include/boost
tar -xvf $BOOST_FILE_PATH -C $WORKDIR
cd $BOOST_SRC_DIR
./bootstrap.sh --prefix=${PREFIX}

cd $BOOST_SRC_DIR

./b2 cxxflags=-fPIC cflags=-fPIC --verbose --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale --build-dir=android --stagedir=android threading=multi threadapi=pthread target-os=linux -sICONV_PATH=${PREFIX} -j$THREADS install
