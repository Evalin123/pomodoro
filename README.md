# 🍅 Pomodoro - 多平台番茄鐘 App

一個優雅的番茄鐘應用程式，使用 Swift 6 與 SwiftUI 開發，支援 iOS、macOS 和 watchOS。

## ✨ 功能特色

### 核心功能

- ⏱️ **預設計時**：25 分鐘工作時間，5 分鐘休息時間
- ▶️ **完整控制**：開始、暫停、重置、模式切換
- 💾 **自動儲存**：使用 @AppStorage 自動保存計時狀態
- 🔄 **自動切換**：工作時間結束後自動進入休息模式

### 平台特色

#### 📱 iPhone

- 簡潔優雅的介面設計，符合 Apple 美學
- 倒數結束時發送**本地通知**提醒
- 支援背景計時

#### 💻 Mac

- 原生 macOS 視窗設計
- 桌面通知提醒
- 固定視窗大小，不干擾工作流程

#### ⌚️ Apple Watch

- 專為小螢幕優化的精簡介面
- 使用 `Text(date, style: .timer)` 確保 **Always-On Display** 模式下準確倒數
- 倒數結束時觸發**觸覺回饋**（震動）
- 超省電設計

## 🏗️ 技術亮點

- **Swift 6** 語法規範
- **嚴格並行檢查**（Strict Concurrency）
- **@MainActor** 確保 UI 執行緒安全
- **Protocol-based 架構**：平台特定功能透過協議抽象
- **共享 ViewModel**：iOS、macOS、watchOS 共用計時邏輯

## 📁 專案結構

```
Pomodoro/
├── Shared/                         # 共享代碼（三平台通用）
│   ├── ViewModels/
│   │   └── TimerViewModel.swift   # 計時邏輯
│   └── Protocols/
│       └── FeedbackProvider.swift # 反饋協議
├── iOS/                            # iOS 專用
│   ├── PomodoroApp.swift
│   ├── ContentView.swift
│   └── NotificationManager.swift  # iOS/macOS 共用
├── macOS/                          # macOS 專用
│   ├── PomodoroApp.swift
│   └── ContentView.swift
└── watchOS/                        # watchOS 專用
    ├── PomodoroApp.swift
    ├── ContentView.swift
    └── HapticManager.swift         # 觸覺回饋
```

## 🚀 快速開始

### 前置需求

- macOS 15.0+
- Xcode 26.3+
- Swift 6.0+
- iOS 17.0+ / macOS 15.0+ / watchOS 10.0+

### 安裝步驟

詳細的專案設定指南請參閱 **[SETUP.md](SETUP.md)**

簡要步驟：

1. 在 Xcode 中建立 Multiplatform App 專案
2. 加入 watchOS target
3. 將對應的原始碼檔案加入各 target
4. 為 iOS 和 macOS target 加入 **Push Notifications** capability
5. 建置並執行

## 🎯 使用方式

### iPhone / Mac

1. 點擊「開始」按鈕啟動 25 分鐘工作計時
2. 倒數結束時會收到通知提醒
3. 自動切換為 5 分鐘休息時間
4. 點擊「暫停」可隨時暫停計時
5. 點擊「重置」回到初始狀態
6. 點擊「切換休息/工作」手動切換模式

### Apple Watch

1. 開啟 Watch App
2. 點擊「開始」按鈕
3. 手錶會震動提醒你時間結束
4. 即使在 Always-On 模式下，時間也會準確倒數

## 📸 截圖

_（建議加入實際截圖）_

## 🛠️ 自訂設定

### 修改計時時長

編輯 `Shared/ViewModels/TimerViewModel.swift`：

```swift
private let workDuration: TimeInterval = 25 * 60  // 工作時間（秒）
private let breakDuration: TimeInterval = 5 * 60  // 休息時間（秒）
```

### 測試模式

測試時可將時間縮短：

```swift
private let workDuration: TimeInterval = 10  // 10 秒
private let breakDuration: TimeInterval = 5   // 5 秒
```

## 🤝 貢獻

歡迎提交 Issue 或 Pull Request！

## 📄 授權

請參閱 [LICENSE](LICENSE) 文件

## 👨‍💻 開發者

使用 Swift 6 與 SwiftUI 開發，適用於 iOS、macOS 和 watchOS。

---

**享受專注的工作時光！🍅⏱️**
