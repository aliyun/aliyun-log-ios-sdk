#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogCrashReporter"
WORKSPACE="AliyunLogProducer.xcodeproj"
PROJECT_BUILDDIR="./build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/${SCHEME}.framework/PrivateHeaders
#rm -rf iphoneos/${SCHEME}.framework/Modules
rm -rf iphoneos/${SCHEME}.framework/_CodeSignature
rm -rf iphonesimulator/${SCHEME}.framework/PrivateHeaders
#rm -rf iphonesimulator/${SCHEME}.framework/Modules
rm -rf iphonesimulator/${SCHEME}.framework/_CodeSignature

cp -r iphoneos/${SCHEME}.framework ./

lipo -remove arm64 ./iphonesimulator/${SCHEME}.framework/${SCHEME} -output ./iphonesimulator/${SCHEME}.framework/${SCHEME}
lipo -create iphoneos/${SCHEME}.framework/${SCHEME} iphonesimulator/${SCHEME}.framework/${SCHEME} -output ${SCHEME}.framework/${SCHEME}

open .
