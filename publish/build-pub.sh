#!/bin/sh
rm -rf build
mkdir build
cp -r ../NetworkDiagnosis/AliNetworkDiagnosis.framework build/AliNetworkDiagnosis.framework
cp -r ../CrashReporter/WPKMobi.xcframework build/WPKMobi.xcframework

sh build-producer.sh
sh build-ot.sh
sh build-core.sh
sh build-crashreporter.sh
sh build-networkdiagnosis.sh

env=lint pod lib lint AliyunLogProducer.podspec --allow-warnings --verbose --no-clean

mkdir -p build/zip/AliNetworkDiagnosis && cp -r build/AliNetworkDiagnosis.framework build/zip/AliNetworkDiagnosis/AliNetworkDiagnosis.framework
mkdir -p build/zip/AliyunLogCore && cp -r build/AliyunLogCore.framework build/zip/AliyunLogCore/AliyunLogCore.framework
mkdir -p build/zip/AliyunLogCrashReporter && cp -r build/AliyunLogCrashReporter.framework build/zip/AliyunLogCrashReporter/AliyunLogCrashReporter.framework
mkdir -p build/zip/AliyunLogNetworkDiagnosis && cp -r build/AliyunLogNetworkDiagnosis.framework build/zip/AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.framework
mkdir -p build/zip/AliyunLogOT && cp -r build/AliyunLogOT.framework build/zip/AliyunLogOT/AliyunLogOT.framework
mkdir -p build/zip/AliyunLogProducer && cp -r build/AliyunLogProducer.framework build/zip/AliyunLogProducer/AliyunLogProducer.framework
mkdir -p build/zip/WPKMobi && cp -r build/WPKMobi.xcframework build/zip/WPKMobi/WPKMobi.xcframework

pushd build/zip
zip -r ../AliyunLogProducer.zip *
popd

open build/zip


