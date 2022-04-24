#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogProducer_Bricks"
# SCHEME_TV="KSCrash_static_tvos"
WORKSPACE="AliyunLogProducer.xcodeproj" 
PROJECT_BUILDDIR="./build"
# PROJECT_BUILDDIR="${BIN_OUTPUT_DIRECTORY}/build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"
# xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_TV} -configuration Release -sdk appletvos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/appletvos"
# xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_TV} -configuration Release -sdk appletvsimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/appletvsimulator"

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

# rm -rf appletvos/WPKMobi.framework/PrivateHeaders
# rm -rf appletvos/WPKMobi.framework/Modules
# rm -rf appletvsimulator/WPKMobi.framework/PrivateHeaders
# rm -rf appletvsimulator/WPKMobi.framework/Modules
# rm -rf appletvsimulator/WPKMobi.framework/_CodeSignature

# xcodebuild -create-xcframework -output "WPKMobi.xcframework" \
#   -framework "iphoneos/WPKMobi.framework" \
#   -framework "iphonesimulator/WPKMobi.framework" \
#   -framework "appletvos/WPKMobi.framework" \
#   -framework "appletvsimulator/WPKMobi.framework"
