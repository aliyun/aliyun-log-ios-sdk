#! /bin/sh
ARCH_LIST=("armv7" "arm64" "x86_64" "i386")
ARCH_COUNT=${#ARCH_LIST[@]}
LIB_NAME="AliyunLogProducer"
EXPORTED_SYMBOLS_LIST="../../exported_symbols.txt"

do_fix()
{
    ARCH=$1;
    echo "fix for ${ARCH}..."

    rm -rf ${ARCH}
    mkdir ${ARCH}

    #  架构抽取
    lipo -thin ${ARCH} ${LIB_NAME}.framework/${LIB_NAME} -output "./${ARCH}/${ARCH}.a"

    # 提取静态库.o目标文件
    cd "./${ARCH}"
    mkdir "objs"
    ar -x "${ARCH}.a"
    `mv *.o objs`
    mv "__.SYMDEF"* "objs"

    # 目标文件提前链接, 这里可以解决符号隐藏后,内部无法链接的问题, 隐藏之前已经链接结束
    cd "objs"
    `ld -r *.o -o combine.o`
    cp "combine.o" ../

    # 输出全局符号作为隐藏符号的来源
    cd ..
    # nm -g -j combine.o > hidden_symbols

    # 剔除指定文件中的全局符号(需要对外开放的符号)
    # `cat ../global_symbols > tmp_symbols`
    # `cat "\n" >> tmp_symbols`
    # `cat hidden_symbols >> tmp_symbols`
    # `sort tmp_symbols|uniq -u > real_hidden_symbols`

    echo "pwd: " `pwd`
    # 重新连接隐藏符号
    ld -x -r -exported_symbols_list ${EXPORTED_SYMBOLS_LIST} combine.o -o hidden.o
    nm -g hidden.o > exist_symbols

    # 生成新的包
    ar -rv "fix.a" hidden.o

    cd ..

}

for ((i=0; i < ${ARCH_COUNT}; i++))
do
do_fix ${ARCH_LIST[i]}
done

LIB_PATHS=( ${ARCH_LIST[@]/#/} )
LIB_PATHS=( ${LIB_PATHS[@]/%//fix.a} )
echo "combine all thin lib to ${LIB_NAME}.framework/${LIB_NAME}"
lipo ${LIB_PATHS[@]} -create -output fix_combine.a
mv fix_combine.a ${LIB_NAME}.framework/${LIB_NAME}
