#!/bin/sh
set -o pipefail
set -e

VERSION=$(cat ../VERSION)
echo "current version: ${VERSION}"

BIN_OUTPUT_DIRECTORY=`pwd`
cd ..

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogNetworkDiagnosis"
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

cp -r iphoneos/${SCHEME}.framework ./

lipo -remove arm64 ./iphonesimulator/${SCHEME}.framework/${SCHEME} -output ./iphonesimulator/${SCHEME}.framework/${SCHEME}
lipo -create iphoneos/${SCHEME}.framework/${SCHEME} iphonesimulator/${SCHEME}.framework/${SCHEME} -output ${SCHEME}.framework/${SCHEME}

# set framework version
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $VERSION" ${SCHEME}.framework/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $VERSION" ${SCHEME}.framework/Info.plist
/usr/libexec/PlistBuddy -c "Set :MinimumOSVersion 100.0" ${SCHEME}.framework/Info.plist

rm -rf iphoneos
rm -rf iphonesimulator

#sh build-xcframework.sh -s "AliyunLogCore" -p "iphoneos iphonesimulator appletvos appletvsimulator macosx macosx_catalyst"
