# 微信输入法 macOS 纯净降级与防前台抢占指南 (WeType Peaceful Edition)

针对微信输入法在 macOS 端 3.0.0+ 版本中强行劫持系统 `Fn` 键、触发语音转文字时强制将前台输入源篡改为微信输入法的问题，本仓库提供官方稳定版本 (v2.1.0) 归档分卷、一键合并恢复脚本以及锁定自动更新配置指南。

---

## ⚖️ 免责声明 (Disclaimer)

1. **版权声明**：本项目中涉及的微信输入法（WeType）安装包及所有相关二进制文件、商标、图形与软件著作权均归属于**深圳市腾讯计算机系统有限公司（Tencent Holdings Limited）**及其关联团队所有。
2. **非商业用途与合法来源**：本项目所载分卷安装包均提取自**腾讯官方公开 CDN 服务器（`download.weread.qq.com`）历史公开发行版本**，未对原始二进制程序、数字签名进行任何逆向篡改、破解、注入或反编译。
3. **技术交流与个人学习**：本项目仅供个人在遇到多输入法冲突场景下的版本回退技术交流、个人备份与学习探讨使用。任何组织或个人不得将本项目用于商业牟利或二次打包分发。
4. **合规提示**：如果权利人认为本仓库内容侵犯了其合法权益，请联系权利通知渠道或提交 Issue，相关文件将在核实后第一时间配合下架移除。

---

## 📌 问题背景与机制对比

在 macOS 上同时使用 **豆包输入法 / 搜狗 / Rime** 作为日常主力打字输入法，同时希望保留微信输入法在后台进行辅助语音转文字时：
* **3.0.0+ 版本的行为**：微信输入法 3.0.0+ 在底层引入了强制抢占逻辑（`input source switch requested`）。只要按下 `Fn` 键触发语音输入，它会强行调用 macOS 输入源接口将前台活跃输入法变更为微信输入法自身，打断当前主力输入法。
* **2.1.0 (Build 601) 的行为**：经过版本逆向对比，`2.1.0` 是最后一个保持**轻量独立浮窗转写、不强制剥夺前台活跃输入法**的稳定版。

---

## 📦 归档文件与分卷信息

为遵守 Git 仓库单文件小于 100MB 的限制，官方原版 zip 安装包已采用标准 `split` 工具切分为 4 个分卷：

* **原始文件**：`WeType_2.1.0_601.zip` (297 MB)
* **SHA-256 校验码**：`bb75e2f50ec94e02c38c488e719d7ac7197a00b13bd697016647fc65b9f039de`
* **分卷目录**：`packages/`
  * `WeType_2.1.0_601.zip.part00` (75 MB)
  * `WeType_2.1.0_601.zip.part01` (75 MB)
  * `WeType_2.1.0_601.zip.part02` (75 MB)
  * `WeType_2.1.0_601.zip.part03` (72 MB)

---

## 🚀 快速使用（一键安装）

你可以直接克隆仓库并执行内置的恢复与锁定脚本：

### 1. 克隆仓库并合并解压
```bash
git clone https://github.com/yzxq1/wetype-mac-peaceful.git
cd wetype-mac-peaceful

# 赋予脚本执行权限
chmod +x install.sh lock.sh

# 执行一键安装（会自动合并分卷并替换到系统输入法目录，需要管理员权限）
./install.sh
```

### 2. 彻底锁定版本，禁止静默更新
微信输入法内置 Sparkle 更新框架。运行锁定脚本切断其后台更新通道，并为偏好配置文件施加只读保护：
```bash
./lock.sh
```

---

## 🛠 手动安装与配置细节

如果你希望手动执行每一步操作：

### 1. 合并分卷并解压
```bash
cat packages/WeType_2.1.0_601.zip.part* > WeType_2.1.0_601.zip
unzip -q WeType_2.1.0_601.zip
```

### 2. 替换输入法程序
```bash
# 退出当前正在运行的微信输入法
pkill -9 -f "/Library/Input Methods/WeType.app" || true

# 替换系统输入法
sudo rm -rf /Library/Input\ Methods/WeType.app
sudo cp -R ./WeType.app /Library/Input\ Methods/WeType.app
sudo chown -R root:staff /Library/Input\ Methods/WeType.app
```

### 3. 锁定偏好设置防止自动升级
```bash
defaults write com.tencent.inputmethod.wetype SUEnableAutomaticChecks -bool false
defaults write com.tencent.inputmethod.wetype SUScheduledCheckInterval -int 999999999
defaults write com.tencent.inputmethod.wetype SUHasLaunchedBefore -bool true

# 施加文件级只读锁
chmod 444 ~/Library/Preferences/com.tencent.inputmethod.wetype.plist
```

---

## 💡 搭配豆包输入法 / 多输入法最佳体验

1. **避免系统上下文乱跳**：
   * 打开 macOS **系统设置 -> 键盘 -> 输入源 -> 编辑**。
   * 取消勾选 **“自动切换到文稿的输入源”**。
2. **前后台分工**：
   * 日常键盘敲击与大模型流式语音交由 **豆包输入法** 处理；
   * 微信输入法在后台常驻待命，提供备用语音转写与隔空互传，互不干扰、永不抢占。
