#!/bin/sh
set -o pipefail
set -e

rm -rf build
mkdir build
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework build/AliNetworkDiagnosis.xcframework
cp -r ../Sources/WPKMobi/WPKMobi.xcframework build/WPKMobi.xcframework

sh build-producer.sh
sh build-ot.sh
sh build-ot-swift.sh
sh build-core.sh
sh build-crashreporter.sh
sh build-networkdiagnosis.sh
sh build-trace.sh
sh build-urlsession.sh
