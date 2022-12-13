#!/bin/bash

. ./config.sh

CW_DIR=${SCRIPTDIR}/../../../flutter_libmonero
CW_EXTERNAL_DIR=${CW_DIR}/cw_shared_external/ios/External/android
CW_MONERO_EXTERNAL_DIR=${CW_DIR}/cw_monero/ios/External/android
LIB_DIR=${CW_EXTERNAL_DIR}/${ABI}/lib
INCLUDE_DIR=${CW_EXTERNAL_DIR}/${ABI}/include
DEST_LIB_DIR=${PREFIX}/lib
DEST_INCLUDE_DIR=${PREFIX}/include
ABI="x86_64";

mkdir -p $CW_MONERO_EXTERNAL_DIR/include
mkdir -p $LIB_DIR
mkdir -p $INCLUDE_DIR
mkdir -p $DEST_LIB_DIR
mkdir -p $DEST_INCLUDE_DIR

cd $WORKDIR/monero/contrib/depends/x86_64-w64-mingw32
find . -path lib -prune -o -name '*.a' -exec cp '{}' lib \; # Copy all .a libraries into /lib from its subfolders
cp -r ./lib/* $DEST_LIB_DIR
cp -r ./include/* $DEST_INCLUDE_DIR

cd $WORKDIR/monero/build
find . -path ./lib -prune -o -name '*.a' -exec cp '{}' lib \; # Copy all .a libraries into /lib from its subfolders
cp -r ./lib/* $DEST_LIB_DIR

# cp ../../src/wallet/api/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include
# cp $PREFIX/include/monero/wallet2_api.h ${CW_MONERO_EXTERNAL_DIR}/include

cp -r ./generated_include/* $DEST_INCLUDE_DIR
# cp ../../src/wallet/api/wallet2_api.h $DEST_INCLUDE_DIR
# cp ../../src/wallet/api/wallet2_api.h $DEST_INCLUDE_DIR

cd $DEST_LIB_DIR

echo "Renaming boost libraries; mv errors here should be treated as warnings"
mv libboost_system-mt-s.a				libboost_system.a
mv libboost_atomic-mt-s.a				libboost_atomic.a
mv libboost_filesystem-mt-s.a			libboost_filesystem.a
mv libboost_program_options-mt-s.a		libboost_program_options.a
mv libboost_unit_test_framework-mt-s.a	libboost_unit_test_framework.a
mv libboost_chrono-mt-s.a				libboost_chrono.a
mv libboost_locale-mt-s.a				libboost_locale.a
mv libboost_regex-mt-s.a				libboost_regex.a
mv libboost_test_exec_monitor-mt-s.a	libboost_test_exec_monitor.a
mv libboost_wserialization-mt-s.a		libboost_wserialization.a
mv libboost_date_time-mt-s.a			libboost_date_time.a
mv libboost_prg_exec_monitor-mt-s.a		libboost_prg_exec_monitor.a
mv libboost_serialization-mt-s.a		libboost_serialization.a
mv libboost_thread-mt-s.a				libboost_thread.a
mv libboost_thread_win32-mt-s.a			libboost_thread.a

# cd $WORKDIR/monero/build

cp -r ${PREFIX}/lib/* $LIB_DIR
cp -r ${PREFIX}/include/* $INCLUDE_DIR
