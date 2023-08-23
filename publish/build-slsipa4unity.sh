#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`
cd ..

APPLICATION_NAME="AliyunLogProducer"
SCHEME="SLSIPA4Unity"
WORKSPACE="AliyunLogSDK.xcodeproj"
PROJECT_BUILDDIR="./publish/build"

rm -rf lib${SCHEME}.a

xcodebuild  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cp ./Sources/SLSIPA4Unity/include/SLSIPA4Unity.h ${PROJECT_BUILDDIR}/SLSIPA4Unity.h

cd ./${PROJECT_BUILDDIR}

lipo -remove arm64 ./iphonesimulator/lib${SCHEME}.a -output ./iphonesimulator/lib${SCHEME}.a
lipo -create iphoneos/lib${SCHEME}.a iphonesimulator/lib${SCHEME}.a -output lib${SCHEME}.a

rm -rf iphoneos
rm -rf iphonesimulator

#cd ..
#sh strip_symbols.sh AliyunLogProducer ../../exported_symbols/producer_symbols.txt

