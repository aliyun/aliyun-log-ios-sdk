#! /bin/sh

set -o pipefail
set -e

PLATFORM_LIST=()
PLATFORM_COUNT=0

ENABLE_DEBUG=0

VERSION=$(cat ../VERSION)
echo "current version: ${VERSION}"

SCHEME="AliyunLogProducer"
SCHEME_SHADOW="AliyunLogProducer"
PROJECT="AliyunLogSDK.xcodeproj"
PROJECT_BUILDDIR="publish/build"

usage()
{
    # productName与target不同时，应该指定shadow scheme为productName
    echo "Usage: $0 [-s <scheme>] [-h <shadow scheme>] [-p <platforms>]."; exit 1;
}

build_framework()
{
    PLATFORM=$1;
    echo "start building ${SCHEME} for ${PLATFORM} ..."

#    iphoneos iphonesimulator appletvos appletvsimulator macosx macosx_catalyst
    generic_platform=""
    final_sdk=${PLATFORM}
    case "${PLATFORM}" in
        "iphoneos") generic_platform="generic/platform=iOS"
        ;;
        "iphonesimulator") generic_platform="generic/platform=iOS Simulator"
        ;;
        "appletvos")  generic_platform="generic/platform=tvOS"
        ;;
        "appletvsimulator")  generic_platform="generic/platform=tvOS Simulator"
        ;;
        "macosx") generic_platform="generic/platform=macOS"
        ;;
        "macosx_catalyst") generic_platform="generic/platform=macOS,variant=Mac Catalyst"; final_sdk="iphoneos"
        ;;
        *)
        echo "not support ${PLATFORM}"; exit 1;
        ;;
    esac

    echo "generic_platform: ${generic_platform}"

    PLATFORM_WORKING_DIRECTORY="${PROJECT_BUILDDIR}/${SCHEME}/${PLATFORM}"

    echo "building ${PLATFORM} for ${SCHEME}. generic_platform: ${generic_platform}, PLATFORM_WORKING_DIRECTORY: ${PLATFORM_WORKING_DIRECTORY}"
    # clean
    xcodebuild clean -project ${PROJECT} -scheme ${SCHEME} -configuration Release
    # archive
    xcodebuild -project ${PROJECT} \
        -scheme ${SCHEME} \
        -configuration Release \
        -destination "${generic_platform}" \
        -archivePath "${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.xcarchive" \
        archive \
        SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    # copy framework to PLATFORM dir
    rm -rf ${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.framework/
    mkdir ${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.framework/

    src="${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.xcarchive/Products/Library/Frameworks/${SCHEME_SHADOW}.framework/"
    dest="${PLATFORM_WORKING_DIRECTORY}/${SCHEME_SHADOW}.framework/"

    if [[ ${PLATFORM} == *"macosx"* ]];
    then src="${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.xcarchive/Products/Library/Frameworks/${SCHEME}.framework/Versions/A/"
    fi

    if [[ ${ENABLE_DEBUG} == 1 ]];
    then
        echo "src: ${src}"
        echo "dest: ${dest}"
    fi

    cp -rf ${src} ${dest}

    # macos specified
    if [[ ${PLATFORM} == *"macosx"* ]];
    then
        cp ${dest}/Resources/Info.plist ${dest}/Info.plist
        rm -rf ${dest}/Resources
        rm -rf ${dest}/Versions
    fi

    # remove invalid info
    rm -rf ${dest}/PrivateHeaders
    rm -rf ${dest}/_CodeSignature
    
    pushd ${dest}
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

    echo "building ${SCHEME} for ${PLATFORM} end."
}

create_xcframework()
{
    echo "start create xcframework ..."
    cmd_frameworks=()
    for ((i=0; i< ${PLATFORM_COUNT}; i++)); do
        cmd_frameworks+=("-framework ${PROJECT_BUILDDIR}/${SCHEME}/${PLATFORM_LIST[i]}/${SCHEME_SHADOW}.framework ")
    done

    if [[ ${ENABLE_DEBUG} == 1 ]];
    then echo "framworks cmd: ${cmd_frameworks[@]}"
    fi

    # create xcframework
    xcodebuild -create-xcframework -output ${PROJECT_BUILDDIR}/${SCHEME_SHADOW}.xcframework ${cmd_frameworks[@]}
}

clean_env()
{
    rm -rf ${PROJECT_BUILDDIR}/${SCHEME}
}

# parameters
while getopts ":s:h:p:d:" opt; do
    case "${opt}" in
        s)
            echo "intput scheme: ${OPTARG}"
            SCHEME=${OPTARG}
            SCHEME_SHADOW=${OPTARG}
        ;;
        h)
            echo "input shadow scheme: ${OPTARG}"
            SCHEME_SHADOW=${OPTARG}
        ;;
        p)
            echo "input platforms: ${OPTARG}"
            IFS=' ' read -ra PLATFORM_LIST <<< "${OPTARG}"
            PLATFORM_COUNT=${#PLATFORM_LIST[@]}
        ;;
        d)
            echo "enable debug mode"
            ENABLE_DEBUG=1
        ;;
        *)
            echo "未知参数!! ${OPTARG}"
            usage
        ;;
    esac
done
shift $((OPTIND-1))

echo "SCHEME: ${SCHEME}, length: ${#SCHEME}, SHADOW_SCHEME: ${SCHEME_SHADOW}, PLATFORM_LIST: ${PLATFORM_LIST[@]}, PLATFORM_COUNT: ${PLATFORM_COUNT}"

if [[ ${#SCHEME} == 0 ]];
then
    echo "scheme must not be empty!!"
    usage
elif [[ ${PLATFORM_COUNT} < 1 ]];
then
    echo "platforms must not be empty!!"
    usage
fi

# prepare env
cd ..
rm -rf ${PROJECT_BUILDDIR}/${SCHEME}
rm -rf ${PROJECT_BUILDDIR}/${SCHEME}.xcframework

# build framework for each platform
for ((i=0; i< ${PLATFORM_COUNT}; i++))
do
    build_framework ${PLATFORM_LIST[i]}
done

# create xcframework
create_xcframework

if [[ ${ENABLE_DEBUG} != 1 ]];
then
    clean_env
fi
