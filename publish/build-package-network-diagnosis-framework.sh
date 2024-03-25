#!/bin/sh
set -o pipefail
set -e

rm -rf build
mkdir build
cp -r ../Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.framework build/AliNetworkDiagnosis.framework

sh build-producer-framework.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogProducer.framework

sh build-networkdiagnosis-framework.sh
codesign --timestamp -v --sign "iPhone Distribution: Taobao (China) Software CO.,LTD" ./build/AliyunLogNetworkDiagnosis.framework

pushd build
zip -q -r ../out/AliyunLogNetworkDiagnosis_framework_$(date "+%Y%m%d_%H%M").zip *
popd
