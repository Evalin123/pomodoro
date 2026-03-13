# Pomodoro App - Xcode 專案設定指南

## 📋 專案概述

這是一個多平台番茄鐘 App，支援 iOS、macOS 和 watchOS。

**功能特色：**

- ⏱️ 預設 25 分鐘工作時間，5 分鐘休息時間
- 📱 iPhone & Mac：倒數結束時發送本地通知
- ⌚️ Apple Watch：使用觸覺回饋 + Always-On Display 支援
- 💾 使用 @AppStorage 自動儲存狀態
- 🎯 Swift 6 語法與嚴格並行檢查

---

## 🚀 在 Xcode 中建立專案

### 步驟 1：建立新專案

1. 開啟 **Xcode 26.3**
2. File → New → Project
3. 選擇 **Multiplatform** 分頁
4. 選擇 **App** 模板
5. 填寫專案資訊：
    - **Product Name**: `Pomodoro`
    - **Team**: 選擇你的開發者帳號
    - **Organization Identifier**: 例如 `com.yourname`
    - **Bundle Identifier**: 會自動生成為 `com.yourname.Pomodoro`
    - **Interface**: SwiftUI
    - **Language**: Swift
    - **Storage**: None（我們使用 @AppStorage）
6. 點擊 **Next**，選擇儲存位置（選擇此 GitHub 資料夾）
7. 點擊 **Create**

### 步驟 2：新增 watchOS Target

1. File → New → Target
2. 選擇 **watchOS** 分頁
3. 選擇 **Watch App**
4. 填寫資訊：
    - **Product Name**: `Pomodoro Watch App`
    - 其他保持預設
5. 點擊 **Finish**
6. 如果詢問是否啟動 scheme，點擊 **Activate**

---

## 📁 整合已建立的檔案

### 步驟 3：移除預設檔案

Xcode 會自動建立一些預設檔案，我們需要移除它們：

1. **iOS 資料夾**：刪除自動生成的 `ContentView.swift` 和 `PomodoroApp.swift`
2. **macOS 資料夾**：同樣刪除自動生成的檔案
3. **watchOS 資料夾**：刪除 Watch App 的預設檔案

### 步驟 4：加入我們的原始碼檔案

#### 4.1 加入 Shared 檔案（iOS + macOS + watchOS 共用）

1. 在 Xcode 左側的專案導覽器，右鍵點擊專案名稱
2. 選擇 **Add Files to "Pomodoro"...**
3. 導覽到 `Shared/` 資料夾
4. 選擇以下檔案：
    - `ViewModels/TimerViewModel.swift`
    - `Protocols/FeedbackProvider.swift`
5. **重要**：勾選以下選項：
    - ✅ Copy items if needed
    - ✅ Create groups
    - **Target Membership**：勾選 **Pomodoro (iOS)**, **Pomodoro (macOS)**, 和 **Pomodoro Watch App**
6. 點擊 **Add**

#### 4.2 加入 iOS 檔案

1. 右鍵點擊專案 → Add Files to "Pomodoro"...
2. 導覽到 `iOS/` 資料夾
3. 選擇所有檔案：
    - `PomodoroApp.swift`
    - `ContentView.swift`
    - `NotificationManager.swift`
4. **Target Membership**：只勾選 **Pomodoro (iOS)** 和 **Pomodoro (macOS)**
    - ⚠️ `NotificationManager.swift` 同時用於 iOS 和 macOS
5. 點擊 **Add**

#### 4.3 加入 macOS 檔案

1. 右鍵點擊專案 → Add Files to "Pomodoro"...
2. 導覽到 `macOS/` 資料夾
3. 選擇：
    - `PomodoroApp.swift`
    - `ContentView.swift`
4. **Target Membership**：只勾選 **Pomodoro (macOS)**
5. 點擊 **Add**

#### 4.4 加入 watchOS 檔案

1. 右鍵點擊專案 → Add Files to "Pomodoro"...
2. 導覽到 `watchOS/` 資料夾
3. 選擇所有檔案：
    - `PomodoroApp.swift`
    - `ContentView.swift`
    - `HapticManager.swift`
4. **Target Membership**：只勾選 **Pomodoro Watch App**
5. 點擊 **Add**

---

## ⚙️ 專案設定

### 步驟 5：設定 iOS Target

1. 在專案導覽器選擇專案根目錄（藍色圖示）
2. 選擇 **Pomodoro (iOS)** target
3. 切換到 **Signing & Capabilities** 分頁：
    - ✅ 確保勾選 **Automatically manage signing**
    - 選擇你的 **Team**
4. 點擊 **+ Capability** 按鈕
5. 搜尋並加入 **Push Notifications**
6. 切換到 **General** 分頁：
    - **Deployment Target**: 設為 **iOS 17.0** 或更高
7. 切換到 **Build Settings** 分頁：
    - 搜尋 `SWIFT_STRICT_CONCURRENCY`
    - 設為 **Complete**
    - 搜尋 `SWIFT_VERSION`
    - 確認為 **6** 或 **6.0**

### 步驟 6：設定 macOS Target

1. 選擇 **Pomodoro (macOS)** target
2. **Signing & Capabilities** 分頁：
    - ✅ Automatically manage signing
    - 選擇你的 **Team**
    - 點擊 **+ Capability** → 加入 **Push Notifications**
    - 如果未啟用，加入 **App Sandbox**
3. **General** 分頁：
    - **Deployment Target**: 設為 **macOS 15.0** 或更高
4. **Build Settings** 分頁：
    - `SWIFT_STRICT_CONCURRENCY` = **Complete**
    - `SWIFT_VERSION` = **6**

### 步驟 7：設定 watchOS Target

1. 選擇 **Pomodoro Watch App** target
2. **Signing & Capabilities** 分頁：
    - ✅ Automatically manage signing
    - 選擇你的 **Team**
3. **General** 分頁：
    - **Deployment Target**: 設為 **watchOS 10.0** 或更高
4. **Build Settings** 分頁：
    - `SWIFT_STRICT_CONCURRENCY` = **Complete**
    - `SWIFT_VERSION` = **6**

---

## 🏗️ 建置與執行

### 步驟 8：修正可能的建置錯誤

由於有些檔案可能重複（例如 `PomodoroApp.swift`），你需要確保每個 target 只有一個 `@main` 入口：

1. 在專案導覽器中，檢查每個檔案的 **Target Membership**（右側面板）
2. 確保：
    - `iOS/PomodoroApp.swift` 只屬於 iOS target
    - `macOS/PomodoroApp.swift` 只屬於 macOS target
    - `watchOS/PomodoroApp.swift` 只屬於 watchOS Watch App target
    - `iOS/ContentView.swift` 只屬於 iOS target
    - `macOS/ContentView.swift` 只屬於 macOS target
    - `watchOS/ContentView.swift` 只屬於 watchOS Watch App target

### 步驟 9：測試各平台

#### 測試 iOS

1. 選擇 scheme：**Pomodoro (iOS)**
2. 選擇模擬器：iPhone 16 Pro 或其他
3. 點擊 **Run** (⌘R)
4. 測試功能：
    - 點擊「開始」→ 應該會請求通知權限
    - 等待倒數（可以修改程式碼縮短時間測試）
    - 切換到背景，等待通知

#### 測試 macOS

1. 選擇 scheme：**Pomodoro (macOS)**
2. 選擇目標：**My Mac**
3. 點擊 **Run**
4. 測試視窗大小、按鈕、通知

#### 測試 watchOS

1. 選擇 scheme：**Pomodoro Watch App**
2. 選擇模擬器：Apple Watch Series 10 (45mm)
3. 點擊 **Run**
4. 測試觸覺回饋（在模擬器上會在終端機看到 log）
5. **實機測試**（強烈建議）：在真實 Apple Watch 上測試觸覺回饋效果

---

## 🐛 常見問題排解

### 問題 1：找不到 `WKInterfaceDevice`

**解決方案**：確保 `HapticManager.swift` 的 Target Membership **只有** watchOS Watch App。

### 問題 2：Multiple commands produce PomodoroApp

**解決方案**：確認每個平台的 `PomodoroApp.swift` 只屬於各自的 target。

### 問題 3：通知不顯示

**解決方案**：

- 確保已在 Signing & Capabilities 加入 Push Notifications
- 在 iOS/macOS 的系統設定中檢查 App 的通知權限
- 前景通知預設不顯示（需實作 `UNUserNotificationCenterDelegate`）

### 問題 4：Swift 6 並行錯誤

**解決方案**：

- 確保 `TimerViewModel` 標記為 `@MainActor`
- 確保 `FeedbackProvider` 協議標記為 `Sendable`
- 檢查 Build Settings 中的 `SWIFT_STRICT_CONCURRENCY`

---

## 📝 注意事項

1. **測試時可縮短時間**：在 `TimerViewModel.swift` 中修改：

    ```swift
    private let workDuration: TimeInterval = 10 // 改為 10 秒測試
    private let breakDuration: TimeInterval = 5
    ```

2. **通知權限**：首次執行會請求權限，如果錯過，需到系統設定手動開啟。

3. **Always-On Display**：watchOS 的 `Text(date, style: .timer)` 天生支援，無需額外設定。

4. **實機測試**：觸覺回饋在模擬器上只會有 log，建議用真實 Apple Watch 測試。

---

## 🎉 完成！

現在你應該有一個完整的多平台番茄鐘 App 了！

**下一步：**

- 自訂工作和休息時間長度
- 加入歷史紀錄功能
- 使用 CloudKit 實現跨裝置同步
- 加入 Widget 支援
- 加入音效

祝你專注工作，享受番茄鐘！🍅
