#!/bin/bash
# macOS 系统默认值一键设置
# 用法: bash mac/set-defaults.sh
# 部分设置需要退出登录或重启后生效

set -euo pipefail

echo "=== macOS 系统偏好设置 ==="

# ============================================================
# NSGlobalDomain — 全局设置
# ============================================================
echo "  → 全局设置"

# 暗色模式
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# 显示所有文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 取消自动纠正/大写/拼写
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# 不保留上次打开应用的窗口
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# 保存面板默认展开
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# 禁止 .DS_Store 写入网络卷
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# 禁用 .DS_Store 写入 USB 卷
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Spring loading（文件夹悬停打开）
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.speed -float 0.5

# 打印完成后退出打印对话框
defaults write com.app.print.PrintingPrefs "Quit When Finished" -bool true

# 点击桌面不隐藏窗口
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# ============================================================
# Dock
# ============================================================
echo "  → Dock 设置"

# 自动隐藏 Dock
defaults write com.apple.dock autohide -bool true
# 移出 Dock 立即显示（无延迟）
defaults write com.apple.dock autohide-delay -float 0
# 收起动画时长
defaults write com.apple.dock autohide-time-modifier -float 0.25
# Dock 图标大小
defaults write com.apple.dock tilesize -int 36
# 不显示最近打开的应用
defaults write com.apple.dock show-recents -bool false
# 最小化效果
defaults write com.apple.dock mineffect -string "scale"
# 最小化到应用图标
defaults write com.apple.dock minimize-to-application -bool true
# Dock 置于底部
defaults write com.apple.dock orientation -string "bottom"

# ============================================================
# Finder
# ============================================================
echo "  → Finder 设置"

# 默认使用列视图
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
# 新窗口打开主目录（PfHm = $HOME, PfDe = 桌面, PfDo = 下载）
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# 搜索当前目录（SCcf = 当前文件夹）
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 显示路径栏
defaults write com.apple.finder ShowPathbar -bool true
# 显示状态栏
defaults write com.apple.finder ShowStatusBar -bool true
# 文件夹排在前
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# 使用列表视图展开时打开子文件夹
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# 桌面显示外置硬盘和可移动介质
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# ============================================================
# 触角（Hot Corners）
# ============================================================
echo "  → 触角设置"

# 右下角 → 快速备忘录 (14)
# 可选值: 0=无, 2=Mission Control, 3=应用窗口, 4=桌面, 5=启动台
#         6=通知中心, 7=Launchpad, 10=开始屏幕保护, 11=禁用屏幕保护
#         12=前台, 13=锁定屏幕, 14=快速备忘录
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

# ============================================================
# 截图
# ============================================================
echo "  → 截图设置"

# 截图默认位置
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# 截图格式 (png/pdf/jpg)
defaults write com.apple.screencapture type -string "png"
# 截图不包含阴影
defaults write com.apple.screencapture disable-shadow -bool false

# ============================================================
# 键盘
# ============================================================
echo "  → 键盘设置"

# 按键重复速度（1=慢, 15=快）
defaults write NSGlobalDomain KeyRepeat -int 2
# 重复前延迟（1=极长, 120000=极短, 15=适中）
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# ============================================================
# 触控板 / 鼠标
# ============================================================
echo "  → 触控板 / 鼠标"

# 触控板轻点点击
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
# 触控板跟手速度 (0-3)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.0
# 鼠标速度 (1-3)
defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.0

# ============================================================
# 活动通知（Crash Reporter）
# ============================================================
echo "  → 其他"

# Crash Reporter 设置为通知（而非弹窗）
defaults write com.apple.CrashReporter DialogType -string "notification"

# 禁止 Time Machine 询问新磁盘
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ============================================================
# 应用以上设置（需要重启的应用）
# ============================================================
echo ""
echo "=== 重启相关服务 ==="

killall Dock 2>/dev/null
killall Finder 2>/dev/null
killall SystemUIServer 2>/dev/null

echo ""
echo "✅ 完成！部分设置需要退出登录或重启后完全生效。"
