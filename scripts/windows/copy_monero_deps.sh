#!/bin/bash

. ./config.sh

CW_DIR=${SCRIPTDIR}/../../../flutter_libmonero
CW_EXTERNAL_DIR=${CW_DIR}/cw_shared_external/ios/External/android
CW_MONERO_EXTERNAL_DIR=${CW_DIR}/cw_monero/ios/External/android
LIB_DIR=${CW_EXTERNAL_DIR}/${ABI}/lib
INCLUDE_DIR=${CW_EXTERNAL_DIR}/${ABI}/include
DEST_LIB_DIR=${PREFIX}/lib/monero
DEST_INCLUDE_DIR=${PREFIX}/include/monero
ABI="x86_64";

cd $WORKDIR/monero/build
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \; # Copy all .a libraries into /lib from its subfolders

mkdir -p $DEST_LIB_DIR
cp -r ./lib/* $DEST_LIB_DIR

mkdir -p $CW_MONERO_EXTERNAL_DIR/include
# cp ../../src/wallet/api/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include
# cp $PREFIX/include/monero/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include

mkdir -p $DEST_INCLUDE_DIR
cp -r ./generated_include/* $DEST_INCLUDE_DIR
# cp ../../src/wallet/api/wallet2_api.h $DEST_INCLUDE_DIR
# cp ../../src/wallet/api/wallet2_api.h $DEST_INCLUDE_DIR

mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR
cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR
