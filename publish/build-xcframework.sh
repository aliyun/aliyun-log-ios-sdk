#! /bin/sh
PLATFORM_LIST=("iphoneos" "iphonesimulator" "appletvos" "appletvsimulator")
PLATFORM_COUNT=${#PLATFORM_LIST[@]}

APPLICATION_NAME="AliyunLogProducer"
SCHEME="AliyunLogProducer"
WORKSPACE="AliyunLogProducer.xcodeproj"
PROJECT_BUILDDIR="publish/build"

build_framework()
{
    PLATFORM=$1;
    echo "start build ${SCHEME} for ${PLATFORM} ..."
    
    IFS=',' read -ra ADDR <<< "$PLATFORM"
    for p in "${ADDR[@]}"; do
        rm -rf ${PROJECT_BUILDDIR}/${p}
        
        xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk ${p} clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/${SCHEME}/${p}"
                
        rm -rf ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework/PrivateHeaders
        rm -rf ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework/_CodeSignature
        
        # remove arm64 arch for simulator
        if [[ $p == *"simulator"* ]];
        then
            echo "found simmulator ${p}, do lipo -remove arm64 command..."
            lipo -remove arm64 ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework/${SCHEME} -output ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework/${SCHEME}
#        else
#            cp -r ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework
        fi
    done
    
#    echo "start create fat framework ..."
#
#    comma="${PLATFORM%%,*}"                     # remove all text after DOT and store in variable s
#    comma_pos=(${#comma} + 1)                   # get string length of $s + 1
#    p1=${PLATFORM:0:$comma_pos}
#    p2=${PLATFORM:$comma_pos+1:${#PLATFORM}}
#    echo "p1: ${p1}"
#    echo "p2: ${p2}"
#
#    lipo -create ${PROJECT_BUILDDIR}/${SCHEME}/${p1}/${SCHEME}.framework/${SCHEME} ${PROJECT_BUILDDIR}/${SCHEME}/${p2}/${SCHEME}.framework/${SCHEME} -output ${PROJECT_BUILDDIR}/${SCHEME}/${p1}/${SCHEME}.framework/${SCHEME}
#
##    rm -rf ${PROJECT_BUILDDIR}/${p1}
#    rm -rf ${PROJECT_BUILDDIR}/${SCHEME}/${p2}
}

# prepare env
rm -rf ${SCHEME}.framework
cd ..

# build framework for each platform
for ((i=0; i< ${PLATFORM_COUNT}; i++))
do build_framework ${PLATFORM_LIST[i]}
done

# build xcframework
#final_platforms=()
#for ((i=0; i< ${PLATFORM_COUNT}; i++))
#do
#    p=${PLATFORM_LIST[i]}
#    comma="${p%%,*}"
#    comma_pos=(${#comma} + 1)
#    p1=${p:0:$comma_pos}
#
#    final_platforms+=(${p1})
#done
#
#echo "${final_platforms[@]}"

cmd="xcodebuild -create-xcframework -output ${PROJECT_BUILDDIR}/${SCHEME}/${SCHEME}.xcframework"
#for p in ${PLATFORM_LIST}
#do
#    echo "p: ${p}"
#    cmd="${cmd} -framework ${PROJECT_BUILDDIR}/${SCHEME}/${p}/${SCHEME}.framework"
#done

for ((i=0; i< ${PLATFORM_COUNT}; i++))
do
    echo "p: ${PLATFORM_LIST[i]}"
    cmd="${cmd} -framework ${PROJECT_BUILDDIR}/${SCHEME}/${PLATFORM_LIST[i]}/${SCHEME}.framework"
done

echo `pwd`
echo "cmd: ${cmd}"
#`${cmd}`

# xcodebuild -create-xcframework -output "WPKMobi.xcframework" \
#   -framework "iphoneos/WPKMobi.framework" \
#   -framework "iphonesimulator/WPKMobi.framework" \
#   -framework "appletvos/WPKMobi.framework" \
#   -framework "appletvsimulator/WPKMobi.framework"
