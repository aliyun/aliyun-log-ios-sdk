#!/bin/sh

WORKSPACE_NAME='AliyunLOGiOS'
PROJECT_NAME=${WORKSPACE_NAME}
DEPENDENCY_NAME='FMDB'
SRCROOT=$(cd "$(dirname "$0")";pwd)

# Sets the target folders and the final framework product.
FMK_NAME=${PROJECT_NAME}

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
INSTALL_DIR_LOGSDK=${SRCROOT}/Products/${PROJECT_NAME}.framework
INSTALL_DIR_FMDB=${SRCROOT}/Products/${DEPENDENCY_NAME}.framework

# Working dir will be deleted after the framework creation.
WRK_DIR=./build
DEVICE_DIR_LOGSDK=${SRCROOT}/build/Build/Products/Release-iphoneos/${FMK_NAME}.framework
SIMULATOR_DIR_LOGSDK=${SRCROOT}/build/Build/Products/Release-iphonesimulator/${FMK_NAME}.framework

DEVICE_DIR_FMDB=${SRCROOT}/build/Build/Products/Release-iphoneos/${DEPENDENCY_NAME}.framework
SIMULATOR_DIR_FMDB=${SRCROOT}/build/Build/Products/Release-iphonesimulator/${DEPENDENCY_NAME}.framework

# -configuration ${CONFIGURATION}
# Clean and Building both architectures.
xcodebuild -configuration "Release" -workspace "${WORKSPACE_NAME}.xcworkspace" -scheme "${FMK_NAME}" -sdk iphoneos clean build -derivedDataPath "${WRK_DIR}"
xcodebuild -configuration "Release" -workspace "${WORKSPACE_NAME}.xcworkspace" -scheme "${FMK_NAME}" -sdk iphonesimulator build -derivedDataPath "${WRK_DIR}"

# Cleaning the oldest.
if [ -d "${INSTALL_DIR}" ]
then
    rm -rf "${INSTALL_DIR}"
fi

mkdir -p ${SRCROOT}/Products

cp -R "${DEVICE_DIR_LOGSDK}" "${INSTALL_DIR_LOGSDK}"
cp -R "${DEVICE_DIR_FMDB}" "${INSTALL_DIR_FMDB}"

# Uses the Lipo Tool to merge both binary files (i386 + armv6/armv7) into one Universal final product.
lipo -create "${DEVICE_DIR_LOGSDK}/${FMK_NAME}" "${SIMULATOR_DIR_LOGSDK}/${FMK_NAME}" -output "${INSTALL_DIR_LOGSDK}/${FMK_NAME}"
lipo -create "${DEVICE_DIR_FMDB}/${DEPENDENCY_NAME}" "${SIMULATOR_DIR_FMDB}/${DEPENDENCY_NAME}" -output "${INSTALL_DIR_FMDB}/${DEPENDENCY_NAME}"

rm -r "${WRK_DIR}"

#if [ -d "${INSTALL_DIR}/_CodeSignature" ]
#then
#    rm -rf "${INSTALL_DIR}/_CodeSignature"
#fi

#if [ -f "${INSTALL_DIR}/Info.plist" ]
#then
#    rm "${INSTALL_DIR}/Info.plist"
#fi
