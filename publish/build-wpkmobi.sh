#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`
cd ..

APPLICATION_NAME="AliyunLogProducer"
SCHEME="WPKMobi"
WORKSPACE="AliyunLogProducer.xcodeproj"
PROJECT_BUILDDIR="./publish/build"

mkdir -p ${PROJECT_BUILDDIR}/iphoneos/
mkdir -p ${PROJECT_BUILDDIR}/iphonesimulator/
cp -r ./CrashReporter/WPKMobi.xcframework/ios-arm64_armv7/WPKMobi.framework ${PROJECT_BUILDDIR}/iphoneos/WPKMobi.framework
cp -r ./CrashReporter/WPKMobi.xcframework/ios-i386_x86_64-simulator/WPKMobi.framework ${PROJECT_BUILDDIR}/iphonesimulator/WPKMobi.framework

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/${SCHEME}.framework/PrivateHeaders
rm -rf iphoneos/${SCHEME}.framework/_CodeSignature

rm -rf iphonesimulator/${SCHEME}.framework/PrivateHeaders
rm -rf iphonesimulator/${SCHEME}.framework/_CodeSignature

cp -r iphoneos/${SCHEME}.framework ./

#lipo -remove arm64 ./iphonesimulator/${SCHEME}.framework/${SCHEME} -output ./iphonesimulator/${SCHEME}.framework/${SCHEME}
lipo -create iphoneos/${SCHEME}.framework/${SCHEME} iphonesimulator/${SCHEME}.framework/${SCHEME} -output ${SCHEME}.framework/${SCHEME}

rm -rf iphoneos
rm -rf iphonesimulator

#cd ..
#sh strip_symbols.sh AliyunLogProducer ../../exported_symbols/producer_symbols.txt

