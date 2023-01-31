#!/bin/sh
set -o pipefail
set -e
rm -rf build
mkdir build

sh build-producer-framework.sh
sh build-ot-framework.sh
sh build-ot-swift-framework.sh
sh build-core-framework.sh
sh build-crashreporter-framework.sh
sh build-unity4sls.sh
sh build-wpkmobi.sh


open build
