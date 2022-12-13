#!/bin/bash

mkdir -p build
mkdir -p cache

./build_monero_deps.sh
./build_monero.sh
# ./build_wownero.sh
# ./build_wownero_seed.sh
./copy_monero_deps.sh
./build_sharedfile.sh
