#!/bin/sh
set -o pipefail
set -e
rm -rf build
mkdir build

sh build-producer-framework.sh
sh build-unity4sls.sh
sh build-slsipa4unity.sh
sh build-wpkmobi.sh

mkdir -p out
pushd build
zip -r ../out/frameworks.zip *
popd
# open build
