#!/bin/sh

. ./config.sh

ICONV_VERSION=1.16
ICONV_SHA256="e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04"
ICONV_FILENAME="libiconv-${ICONV_VERSION}.tar.gz"
ICONV_SRC_DIR="${WORKDIR}/libiconv-${ICONV_VERSION}"
ICONV_FILE_PATH=$CACHEDIR/$ICONV_FILENAME

echo $ICONV_FILENAME
echo $ICONV_FILE_PATH

if [ ! -e "$ICONV_FILE_PATH" ]; then
  curl http://ftp.gnu.org/pub/gnu/libiconv/$ICONV_FILENAME -o $ICONV_FILE_PATH
fi

echo $ICONV_SHA256 $ICONV_FILE_PATH | sha256sum -c - || exit 1

cd $WORKDIR
rm -rf $ICONV_SRC_DIR
tar -xzf $ICONV_FILE_PATH -C $WORKDIR
cd $ICONV_SRC_DIR

./configure \
	--host=${HOST} \
	--prefix=${PREFIX} \
	--enable-static \
	--disable-shared \
	--disable-rpath
make -j$THREADS
make install
