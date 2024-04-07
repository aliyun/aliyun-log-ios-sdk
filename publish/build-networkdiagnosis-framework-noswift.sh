#!/bin/sh
set -e

VERSION=$(cat ../VERSION)
echo "current version: ${VERSION}"

BIN_OUTPUT_DIRECTORY=`pwd`
cd ..

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogNetworkDiagnosis-NoSwift"
SCHEME_SHADOW="AliyunLogNetworkDiagnosis"
WORKSPACE="AliyunLogSDK.xcodeproj"
PROJECT_BUILDDIR="./publish/build"

rm -rf ${SCHEME}.framework

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/${SCHEME}.framework/PrivateHeaders
rm -rf iphoneos/${SCHEME}.framework/_CodeSignature

rm -rf iphonesimulator/${SCHEME}.framework/PrivateHeaders
rm -rf iphonesimulator/${SCHEME}.framework/_CodeSignature

cp -r iphoneos/${SCHEME_SHADOW}.framework ./

lipo -remove arm64 ./iphonesimulator/${SCHEME_SHADOW}.framework/${SCHEME_SHADOW} -output ./iphonesimulator/${SCHEME_SHADOW}.framework/${SCHEME_SHADOW}
lipo -create iphoneos/${SCHEME_SHADOW}.framework/${SCHEME_SHADOW} iphonesimulator/${SCHEME_SHADOW}.framework/${SCHEME_SHADOW} -output ${SCHEME_SHADOW}.framework/${SCHEME_SHADOW}

# set framework version
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $VERSION" ${SCHEME_SHADOW}.framework/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $VERSION" ${SCHEME_SHADOW}.framework/Info.plist
/usr/libexec/PlistBuddy -c "Set :MinimumOSVersion 100.0" ${SCHEME_SHADOW}.framework/Info.plist

rm -rf iphoneos
rm -rf iphonesimulator

#sh build-xcframework.sh -s "AliyunLogCore" -p "iphoneos iphonesimulator appletvos appletvsimulator macosx macosx_catalyst"
