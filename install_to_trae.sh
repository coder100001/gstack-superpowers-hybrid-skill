#!/bin/bash

# 安装脚本 - 将 gstack-superpowers-hybrid-skill 复制到 ~/.trae-cn/superpowers

set -e

# 配置
SOURCE_DIR="/Users/liunian/Desktop/dnmp/gstack-superpowers-hybrid-skill"
TARGET_DIR="$HOME/.trae-cn/superpowers"
BACKUP_DIR="$HOME/.trae-cn/superpowers.backup.$(date +%Y%m%d_%H%M%S)"

echo "======================================"
echo "  gstack-superpowers-hybrid-skill 安装"
echo "======================================"
echo ""
echo "源目录: $SOURCE_DIR"
echo "目标目录: $TARGET_DIR"
echo ""

# 检查源目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录不存在: $SOURCE_DIR"
    exit 1
fi

# 备份现有目录（如果存在）
if [ -d "$TARGET_DIR" ]; then
    echo "备份现有目录到: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    echo "备份完成"
    echo ""
fi

# 创建目标目录并复制
echo "正在复制文件..."
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_DIR/"* "$TARGET_DIR/"

echo ""
echo "======================================"
echo "  安装完成！"
echo "======================================"
echo ""
echo "新的技能包已安装到: $TARGET_DIR"
echo ""
echo "目录结构:"
ls -la "$TARGET_DIR"
echo ""
echo "如果需要回滚，请使用:"
echo "  rm -rf $TARGET_DIR"
echo "  mv $BACKUP_DIR $TARGET_DIR"
echo ""
