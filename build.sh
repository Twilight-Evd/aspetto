#!/bin/bash

# 检查是否提供了平台参数
if [ -z "$1" ]; then
    echo "请提供目标平台参数，例如：./build.sh windows 或 ./build.sh macos"
    exit 1
fi

TARGET_OS=$1

echo "准备编译 $TARGET_OS 环境"
# 将 pubspec_main.yaml 的内容复制到 pubspec.yaml


# 根据平台条件性地追加 fonts 配置
if [ "$TARGET_OS" == "windows" ]; then

    echo "$TARGET_OS 环境需要打包字体，准备备份pubspec.yaml"
    cp pubspec.yaml pubspec.yaml.tmp
    echo "备份完成"
    echo "copy字体部分"
    cat pubspec_fonts.yaml >> pubspec.yaml
    echo "完成copy"
fi

# 执行 flutter 打包
echo "开始清理环境"
flutter clean
echo "完成"
echo "开始获取依赖"
flutter pub get --no-example
echo "完成"
echo "开始编译环境"
flutter build $TARGET_OS --release 
echo "编译完成"
if [ "$TARGET_OS" == "windows" ]; then
    echo "$TARGET_OS 环境恢复备份pubspec.yaml"
    cp pubspec.yaml.tmp pubspec.yaml 
    echo "完成"
fi