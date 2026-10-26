#!/bin/bash
set -e

echo "=== 正在锁定微信输入法版本，禁止自动检查与后台更新 ==="

# 1. 写入 Sparkle 框架禁止自动更新配置
defaults write com.tencent.inputmethod.wetype SUEnableAutomaticChecks -bool false
defaults write com.tencent.inputmethod.wetype SUScheduledCheckInterval -int 999999999
defaults write com.tencent.inputmethod.wetype SUHasLaunchedBefore -bool true

# 2. 锁定偏好文件为只读
PREF_PATH="$HOME/Library/Preferences/com.tencent.inputmethod.wetype.plist"
if [ -f "$PREF_PATH" ]; then
    chmod 444 "$PREF_PATH"
    echo "✅ 已为 $PREF_PATH 施加只读锁 (chmod 444)"
fi

echo "✅ 微信输入法已成功锁定！不会再静默拉取更新。"
