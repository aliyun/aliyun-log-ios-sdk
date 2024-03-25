#!/bin/sh
set -o pipefail
set -e

rm -rf build
mkdir build
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework build/AliNetworkDiagnosis.xcframework

sh build-producer.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogProducer.xcframework

sh build-networkdiagnosis-noswift.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogNetworkDiagnosis.xcframework

pushd build
zip -q -r ../out/AliyunLogNetworkDiagnosis_xcframework_noswift_$(date "+%Y%m%d_%H%M").zip *
popd
