#!/usr/bin/env bash

# ----------------- 基本命令如下 --------------------
# lipo -info MobileRTC.framework/MobileRTC
# lipo MobileRTC.framework/MobileRTC -thin arm64 -output MobileRTC.framework/MobileRTC-arm64
# lipo MobileRTC.framework/MobileRTC -thin armv7 -output MobileRTC.framework/MobileRTC-armv7
# lipo -create MobileRTC.framework/MobileRTC-armv7 MobileRTC.framework/MobileRTC-arm64 -output MobileRTC.framework/MobileRTC-new

ORIGINF=$1


if [ ! -f "$ORIGINF" ]; then
    echo "Error: $ORIGINF 文件不存在";
    exit
fi

DIR=$(dirname "$ORIGINF")
FILENAME=$(basename "$ORIGINF")

# 中间文件
NEWF=${FILENAME}"-new"

#echo;echo "所在目录 '$DIR', 文件名称 $FILENAME";

# 进入到指定目录下，可以避免下面处理带空格的路径
cd "$DIR"

# ---------- 变量处理 ⤴️-------------------------------
echo "--------------------- 正在生成中..... ---------------------"

LIPOINFO=$(lipo -info "$FILENAME")

DESARCNAMES=("armv7" "armv7s" "arm64")

# 拼接生成新framework的命令字符串
LIPOCMD="lipo -create "

for i in "${!DESARCNAMES[@]}"; do
    CARC=$(echo "$LIPOINFO" | grep ${DESARCNAMES[$i]})
#    echo;echo "carc="$CARC
    if [[ ! -z $CARC ]]; then
        CARC=${DESARCNAMES[$i]};
        lipo "$FILENAME" -thin ${DESARCNAMES[$i]} -output "$CARC"
        echo -e "----生成${CARC}-->"$CARC;  # 使用-e,使\n生效
    fi

    DESARCNAMES[$i]=$CARC
    LIPOCMD+=${DESARCNAMES[$i]}" "
    #ARCS+=" "
#    echo "$i ${DESARCNAMES[$i]} ${LIPOCMD}"
done

DESTFILE=${NEWF};
rm -f "$DESTFILE"; touch "$DESTFILE"

LIPOCMD+=" -output $DESTFILE"
echo "----正在生成 $DESTFILE";

#echo ${LIPOCMD}

# 执行字符串命令
#$LIPOCMD # 或
eval $LIPOCMD


echo "----正在删除临时及原始文件 $FILENAME";
# 将中间及原始文件都删除掉
rm -f ${DESARCNAMES[0]} ${DESARCNAMES[1]} ${DESARCNAMES[2]} $FILENAME

echo "----正在将 $DESTFILE 重命名为 $FILENAME";
# 修改目标文件为原始文件名称
mv $DESTFILE $FILENAME

echo "--------------------- 成功.... ---------------------"

exit
# ----------- 脚本到此结束 --------------


# 以下代码是对上面for循环的展开写法
#ARMV7=$(echo "$LIPOINFO" | grep "armv7")
#if [[ "$ARMV7" != "" ]]; then
#    ARMV7=${FILENAME}"-armv7";
#    lipo "$FILENAME" -thin armv7 -output "$ARMV7"
#    echo -e "\n生成armv7:"$ARMV7;  # 使用-e,使\n生效
#fi
#
#ARMV7S=$(echo "$LIPOINFO" | grep "armv7s")
#if [[ "$ARMV7S" != "" ]]; then
#    ARMV7S=${FILENAME}"-armv7s";
#    lipo "$FILENAME" -thin armv7s -output "$ARMV7S"
#    echo -e "\n生成armv7s:"$ARMV7S;
#fi
#
#ARM64=$(echo "$LIPOINFO" | grep "arm64")
#if [[ "$ARM64" != "" ]]; then
#    ARM64=${FILENAME}"-arm64";
#    lipo "$FILENAME" -thin arm64 -output "$ARM64"
#    echo -e "\n生成arm64:"$ARM64;
#fi




