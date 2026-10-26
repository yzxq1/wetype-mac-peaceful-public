#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=== 正在合并分卷包并校验 ==="
cat packages/WeType_2.1.0_601.zip.part* > WeType_2.1.0_601.zip

EXPECTED_HASH="bb75e2f50ec94e02c38c488e719d7ac7197a00b13bd697016647fc65b9f039de"
ACTUAL_HASH=$(shasum -a 256 WeType_2.1.0_601.zip | awk '{print $1}')

if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
    echo "❌ 校验失败：合并后的压缩包哈希不匹配！"
    rm -f WeType_2.1.0_601.zip
    exit 1
fi
echo "✅ SHA256 校验通过！"

echo "=== 正在解压安装包 ==="
unzip -q -o WeType_2.1.0_601.zip

echo "=== 正在替换系统输入法（需要输入管理员密码） ==="
pkill -9 -f "/Library/Input Methods/WeType.app" 2>/dev/null || true

sudo rm -rf /Library/Input\ Methods/WeType.app
sudo cp -R WeType.app /Library/Input\ Methods/WeType.app
sudo chown -R root:staff /Library/Input\ Methods/WeType.app

# 清理中间产生的未打包文件
rm -rf WeType.app WeType_2.1.0_601.zip

echo "✅ 微信输入法已成功降级至 2.1.0 (build 601)！"
echo "建议紧接着运行 ./lock.sh 锁死自动更新。"
