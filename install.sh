#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=== 正在合并分卷包并校验 ==="
cat packages/WeType_2.2.2_643.zip.part* > WeType_2.2.2_643.zip

EXPECTED_HASH="2dd9072c4a2b1ada9d664736ebb2f1d952348da09b85cb178727fc80b69b6ee9"
ACTUAL_HASH=$(shasum -a 256 WeType_2.2.2_643.zip | awk '{print $1}')

if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
    echo "❌ 校验失败：合并后的压缩包哈希不匹配！"
    rm -f WeType_2.2.2_643.zip
    exit 1
fi
echo "✅ SHA256 校验通过！"

echo "=== 正在解压安装包 ==="
unzip -q -o WeType_2.2.2_643.zip

echo "=== 正在替换系统输入法（需要输入管理员密码） ==="
pkill -9 -f "/Library/Input Methods/WeType.app" 2>/dev/null || true

sudo rm -rf /Library/Input\ Methods/WeType.app
sudo cp -R WeType.app /Library/Input\ Methods/WeType.app
sudo chown -R root:staff /Library/Input\ Methods/WeType.app

# 清理中间产生的未打包文件
rm -rf WeType.app WeType_2.2.2_643.zip

echo "✅ 微信输入法已成功恢复至 2.2.2 (build 643)！"
echo "建议紧接着运行 ./lock.sh 锁死自动更新。"
