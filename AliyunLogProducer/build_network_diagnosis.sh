#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="AliyunLogProducer"
SCHEME_CRASH="NetworkDiagnosis"
WORKSPACE="AliyunLogProducer.xcodeproj" 
PROJECT_BUILDDIR="./build"
# PROJECT_BUILDDIR="${BIN_OUTPUT_DIRECTORY}/build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_CRASH} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_CRASH} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/${SCHEME_CRASH}.framework/PrivateHeaders
rm -rf iphoneos/${SCHEME_CRASH}.framework/Modules
rm -rf iphoneos/${SCHEME_CRASH}.framework/_CodeSignature
rm -rf iphonesimulator/${SCHEME_CRASH}.framework/PrivateHeaders
rm -rf iphonesimulator/${SCHEME_CRASH}.framework/Modules
rm -rf iphonesimulator/${SCHEME_CRASH}.framework/_CodeSignature

cp -r iphoneos/${SCHEME_CRASH}.framework ./

lipo -remove arm64 ./iphonesimulator/${SCHEME_CRASH}.framework/${SCHEME_CRASH} -output ./iphonesimulator/${SCHEME_CRASH}.framework/${SCHEME_CRASH}
lipo -create iphoneos/${SCHEME_CRASH}.framework/${SCHEME_CRASH} iphonesimulator/${SCHEME_CRASH}.framework/${SCHEME_CRASH} -output ${SCHEME_CRASH}.framework/${SCHEME_CRASH}

open .
