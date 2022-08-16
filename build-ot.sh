#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="AliyunLogProducer"
SCHEME="OT"
WORKSPACE="AliyunLogProducer.xcodeproj"
PROJECT_BUILDDIR="./build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/OT.framework/PrivateHeaders
rm -rf iphoneos/OT.framework/Modules
rm -rf iphoneos/OT.framework/_CodeSignature
rm -rf iphonesimulator/OT.framework/PrivateHeaders
rm -rf iphonesimulator/OT.framework/Modules
rm -rf iphonesimulator/OT.framework/_CodeSignature

cp -r iphoneos/OT.framework ./

lipo -remove arm64 ./iphonesimulator/OT.framework/OT -output ./iphonesimulator/OT.framework/OT
lipo -create iphoneos/OT.framework/OT iphonesimulator/OT.framework/OT -output OT.framework/OT

open .
