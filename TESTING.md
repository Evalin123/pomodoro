# 🚀 快速測試指南

## 一鍵生成並測試

使用 XcodeGen，你現在可以用**一個命令**生成完整的 Xcode 專案！

### 📋 前置需求

```bash
# 安裝 XcodeGen（已完成）
brew install xcodegen
```

### ⚡️ 快速開始

```bash
# 方法 1：使用腳本（推薦）
./generate-project.sh

# 方法 2：手動生成
xcodegen generate
open Pomodoro.xcodeproj
```

### 🎯 腳本選項

執行 `./generate-project.sh` 後，選擇：

1. **iOS** - 自動編譯並啟動 iOS 模擬器
2. **macOS** - 編譯 macOS 版本
3. **watchOS** - 自動編譯並啟動 Apple Watch 模擬器
4. **只打開專案** - 手動測試

### 📁 檔案結構

```
Pomodoro/
├── project.yml              # XcodeGen 配置（版本控制）
├── generate-project.sh      # 一鍵生成腳本
├── Pomodoro.xcodeproj      # 生成的專案（不提交到 Git）
├── Shared/                  # 共享代碼
├── iOS/                     # iOS 專用
├── macOS/                   # macOS 專用
└── watchOS/                 # watchOS 專用
```

### 🎨 優勢

✅ **不用手動創建 Xcode 專案**
✅ **版本控制友好**（只提交 project.yml）
✅ **團隊協作更容易**（避免合併衝突）
✅ **一致的專案設置**
✅ **支援所有三個平台**

### 🔧 自訂配置

編輯 `project.yml` 來修改：

- Bundle ID
- Deployment Target
- Capabilities
- Build Settings

然後重新執行 `./generate-project.sh` 即可。

### 📝 注意事項

- ⚠️ `.xcodeproj` 已加入 `.gitignore`，不會提交到 Git
- ⚠️ 修改專案設置請編輯 `project.yml`，不要直接在 Xcode 中修改
- ⚠️ 每次修改 `project.yml` 後需要重新生成專案

### 🆚 對比傳統方式

**傳統方式：**

1. 打開 Xcode
2. File → New → Project
3. 選擇模板和平台
4. 手動加入文件
5. 設定 Capabilities
6. 配置 Build Settings
7. 重複 for 每個平台

**現在：**

```bash
./generate-project.sh
```

完成！🎉

---

### 🐛 問題排解

**問題：`xcodegen: command not found`**

```bash
brew install xcodegen
```

**問題：生成失敗**

```bash
# 檢查 project.yml 語法
xcodegen generate --spec project.yml
```

**問題：找不到文件**
確保所有源代碼文件都在正確的資料夾中。
