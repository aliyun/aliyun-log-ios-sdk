#! /bin/sh

#set -o pipefail
set -e

PLATFORM_LIST=()
PLATFORM_COUNT=0

ENABLE_DEBUG=0

SCHEME="AliyunLogProducer"
PROJECT="AliyunLogSDK.xcodeproj"
PROJECT_BUILDDIR="publish/build"

usage()
{
    echo "Usage: $0 [-s <scheme>] [-s <platforms>]"; exit 1;
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
    xcodebuild OTHER_CFLAGS="-fembed-bitcode" clean -project ${PROJECT} -scheme ${SCHEME} -configuration Release
    # archive
    xcodebuild OTHER_CFLAGS="-fembed-bitcode" \
        -project ${PROJECT} \
        -scheme ${SCHEME} \
        -configuration Release \
        -destination "${generic_platform}" \
        -archivePath "${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.xcarchive" \
        archive \
        SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    # copy framework to PLATFORM dir
    rm -rf ${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.framework/
    mkdir ${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.framework/

    src="${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.xcarchive/Products/Library/Frameworks/${SCHEME}.framework/"
    dest="${PLATFORM_WORKING_DIRECTORY}/${SCHEME}.framework/"

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

    echo "building ${SCHEME} for ${PLATFORM} end."
}

create_xcframework()
{
    echo "start create xcframework ..."
    cmd_frameworks=()
    for ((i=0; i< ${PLATFORM_COUNT}; i++)); do
        cmd_frameworks+=("-framework ${PROJECT_BUILDDIR}/${SCHEME}/${PLATFORM_LIST[i]}/${SCHEME}.framework ")
    done

    if [[ ${ENABLE_DEBUG} == 1 ]];
    then echo "framworks cmd: ${cmd_frameworks[@]}"
    fi

    # create xcframework
    xcodebuild -create-xcframework -output ${PROJECT_BUILDDIR}/${SCHEME}.xcframework ${cmd_frameworks[@]}
}

clean_env()
{
    rm -rf ${PROJECT_BUILDDIR}/${SCHEME}
}

# parameters
while getopts ":s:p:d:" opt; do
    case "${opt}" in
        s)
            echo "intput scheme: ${OPTARG}"
            SCHEME=${OPTARG}
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

echo "SCHEME: ${SCHEME}, length: ${#SCHEME}, PLATFORM_LIST: ${PLATFORM_LIST[@]}, PLATFORM_COUNT: ${PLATFORM_COUNT}"

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
