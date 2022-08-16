#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogProducer"
WORKSPACE="AliyunLogProducer.xcodeproj"
PROJECT_BUILDDIR="./build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/AliyunLogProducer.framework/PrivateHeaders
rm -rf iphoneos/AliyunLogProducer.framework/Modules
rm -rf iphoneos/AliyunLogProducer.framework/_CodeSignature
rm -rf iphonesimulator/AliyunLogProducer.framework/PrivateHeaders
rm -rf iphonesimulator/AliyunLogProducer.framework/Modules
rm -rf iphonesimulator/AliyunLogProducer.framework/_CodeSignature

cp -r iphoneos/AliyunLogProducer.framework ./

lipo -remove arm64 ./iphonesimulator/AliyunLogProducer.framework/AliyunLogProducer -output ./iphonesimulator/AliyunLogProducer.framework/AliyunLogProducer
lipo -create iphoneos/AliyunLogProducer.framework/AliyunLogProducer iphonesimulator/AliyunLogProducer.framework/AliyunLogProducer -output AliyunLogProducer.framework/AliyunLogProducer

open .
