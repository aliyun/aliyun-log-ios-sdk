#!/bin/sh
set -o pipefail
set -e

rm -rf build
mkdir build
mkdir -p out/$(date "+%Y%m%d")
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework build/AliNetworkDiagnosis.xcframework

sh build-producer.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogProducer.xcframework

sh build-networkdiagnosisone.sh
# remove URLSessionInstrumentation. from .swiftinterface files to remove the URLSessionInstrumentation module references.
# https://forums.developer.apple.com/forums/thread/123253
pushd ./build/AliyunLogNetworkDiagnosisOne.xcframework
find . -name "*.swiftinterface" -exec sed -i '' 's/AliNetworkDiagnosis\.//g' {} \;
popd

codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogNetworkDiagnosisOne.xcframework

pushd build
zip -q -r ../out/$(date "+%Y%m%d")/AliyunLogNetworkDiagnosisOne_xcframework_$(date "+%Y%m%d_%H%M").zip *
popd
