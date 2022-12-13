#!/bin/bash

WORKDIR="$(pwd)/"build
CW_DIR="$(pwd)"/../../../flutter_libmonero
CW_EXTERNAL_DIR=${CW_DIR}/cw_shared_external/ios/External/android
CW_MONERO_EXTERNAL_DIR=${CW_DIR}/cw_monero/ios/External/android
for arch in $TYPES_OF_BUILD
do

ABI="x86_64";


LIB_DIR=${CW_EXTERNAL_DIR}/prefix_${ABI}/lib
INCLUDE_DIR=${CW_EXTERNAL_DIR}/prefix_${ABI}/include

mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR

cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR


mkdir -p ${CW_MONERO_EXTERNAL_DIR}/include

cp $PREFIX/include/monero/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include

done