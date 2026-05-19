#!/bin/bash
# Ice 菜单栏管理器配置导入
# 使用: bash mac/ice-setup.sh

set -euo pipefail

PLIST="$(dirname "$0")/ice.plist"

if [ ! -f "$PLIST" ]; then
    echo "错误: 找不到 $PLIST"
    echo "请确认路径正确"
    exit 1
fi

echo "导入 Ice 配置..."
defaults import com.jordanbaird.Ice "$PLIST"
echo "完成！请重启 Ice 应用:"
echo "  killall Ice && open /Applications/Ice.app"
