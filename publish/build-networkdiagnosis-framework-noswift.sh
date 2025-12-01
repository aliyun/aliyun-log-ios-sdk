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

pushd ${SCHEME_SHADOW}.framework
export _version_=$VERSION

# set framework version
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $VERSION" -c "Set CFBundleShortVersionString $VERSION" Info.plist

# compatible for Xcode 15.3
# https://github.com/Azure/azure-spatial-anchors-samples/issues/407#issuecomment-1755051174
# Check if the MinimumOSVersion key exists in the Info.plist
if /usr/libexec/PlistBuddy -c "Print :MinimumOSVersion" Info.plist >/dev/null 2>&1; then
  # Key exists, so update its value
  /usr/libexec/PlistBuddy -c "Set :MinimumOSVersion 100.0" Info.plist
fi

# compatible for xcprivacy
find . -name "*.bundle" -type d -exec sh -c '
    for bundle in "$PWD/$@"; do
        echo "bundle path: $bundle"
        find "$bundle" -name "Info.plist" -exec /usr/libexec/PlistBuddy \
            -c "Set :CFBundleVersion $_version_" \
            -c "Set :CFBundleShortVersionString $_version_" \
            -c "Delete :CFBundleExecutable $_version_" "{}" \;
            
        for file in "$bundle"/*; do
            if [[ "$file" != */Info.plist ]] && [[ "$file" != */PrivacyInfo.xcprivacy ]]; then
                echo "deleting file: $file"
                rm -rf "$file"
            fi
        done
    done
' sh {} +
popd

rm -rf iphoneos
rm -rf iphonesimulator

#sh build-xcframework.sh -s "AliyunLogCore" -p "iphoneos iphonesimulator appletvos appletvsimulator macosx macosx_catalyst"
