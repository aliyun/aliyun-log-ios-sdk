#!/bin/sh
set -o pipefail
set -e

rm -rf build
mkdir build
mkdir -p out/$(date "+%Y%m%d")
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.framework build/AliNetworkDiagnosis.framework

sh build-producer-framework.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogProducer.framework

sh build-networkdiagnosis-framework.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogNetworkDiagnosis.framework

pushd build
zip -q -r ../out/$(date "+%Y%m%d")/AliyunLogNetworkDiagnosis_framework_$(date "+%Y%m%d_%H%M").zip *
popd
