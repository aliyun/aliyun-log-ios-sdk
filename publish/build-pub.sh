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

env=lint pod lib lint AliyunLogProducer.podspec --allow-warnings

mkdir -p build/zip/AliNetworkDiagnosis && cp -r build/AliNetworkDiagnosis.framework build/zip/AliNetworkDiagnosis/AliNetworkDiagnosis.framework
mkdir -p build/zip/WPKMobi && cp -r build/WPKMobi.xcframework build/zip/WPKMobi/WPKMobi.xcframework

mkdir -p build/zip/AliyunLogProducer && cp -r build/AliyunLogProducer.xcframework build/zip/AliyunLogProducer/AliyunLogProducer.xcframework
mkdir -p build/zip/AliyunLogOT && cp -r build/AliyunLogOT.xcframework build/zip/AliyunLogOT/AliyunLogOT.xcframework
mkdir -p build/zip/AliyunLogOTSwift && cp -r build/AliyunLogOTSwift.xcframework build/zip/AliyunLogOTSwift/AliyunLogOTSwift.xcframework
mkdir -p build/zip/AliyunLogCore && cp -r build/AliyunLogCore.xcframework build/zip/AliyunLogCore/AliyunLogCore.xcframework
mkdir -p build/zip/AliyunLogCrashReporter && cp -r build/AliyunLogCrashReporter.xcframework build/zip/AliyunLogCrashReporter/AliyunLogCrashReporter.xcframework
mkdir -p build/zip/AliyunLogNetworkDiagnosis && cp -r build/AliyunLogNetworkDiagnosis.framework build/zip/AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.framework
mkdir -p build/zip/AliyunLogTrace && cp -r build/AliyunLogTrace.xcframework build/zip/AliyunLogTrace/AliyunLogTrace.xcframework

pushd build/zip
zip -r ../AliyunLogProducer.zip *
popd

open build/zip
