#!/bin/sh
#BIN_OUTPUT_DIRECTORY=`pwd`
#cd ..
#
#APPLICATION_NAME="AliyunLogProducer"
#SCHEME="AliyunLogNetworkDiagnosis"
#WORKSPACE="AliyunLogProducer.xcodeproj"
#PROJECT_BUILDDIR="./publish/build"
#
#rm -rf ${SCHEME}.framework
#
#xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
#xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"
#
#cd ./${PROJECT_BUILDDIR}
#rm -rf iphoneos/${SCHEME}.framework/PrivateHeaders
#rm -rf iphoneos/${SCHEME}.framework/_CodeSignature
#
#rm -rf iphonesimulator/${SCHEME}.framework/PrivateHeaders
#rm -rf iphonesimulator/${SCHEME}.framework/_CodeSignature
#
#cp -r iphoneos/${SCHEME}.framework ./
#
#lipo -remove arm64 ./iphonesimulator/${SCHEME}.framework/${SCHEME} -output ./iphonesimulator/${SCHEME}.framework/${SCHEME}
#lipo -create iphoneos/${SCHEME}.framework/${SCHEME} iphonesimulator/${SCHEME}.framework/${SCHEME} -output ${SCHEME}.framework/${SCHEME}
#
#rm -rf iphoneos
#rm -rf iphonesimulator

#!/bin/sh

sh build-xcframework.sh -s "AliyunLogURLSessionInstrumentation" -p "iphoneos iphonesimulator"
# remove URLSessionInstrumentation. from .swiftinterface files to remove the URLSessionInstrumentation module references.
# https://forums.developer.apple.com/forums/thread/123253
pushd ./build/AliyunLogURLSessionInstrumentation.xcframework
find . -name "*.swiftinterface" -exec sed -i '' 's/AliyunLogURLSessionInstrumentation\.//g' {} \;
find . -name "*.swiftinterface" -exec sed -i '' -E 's/([^A-Za-z0-9])URLSessionInstrumentation\./\1/g' {} +
popd
