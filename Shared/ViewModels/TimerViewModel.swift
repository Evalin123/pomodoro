//
//  TimerViewModel.swift
//  Pomodoro
//
//  Created on 2026/3/12.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Session Model
struct Session: Identifiable, Codable {
    let id: UUID
    let type: SessionType
    let duration: TimeInterval
    let timestamp: Date
    
    enum SessionType: String, Codable {
        case focus = "focus"
        case `break` = "break"
    }
    
    init(id: UUID = UUID(), type: SessionType, duration: TimeInterval, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.duration = duration
        self.timestamp = timestamp
    }
}

@MainActor
class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning: Bool = false
    @Published var isWorkMode: Bool = true
    @Published var targetDate: Date?
    @Published var sessions: [Session] = []  // 會話歷史（記憶體存儲）
    @Published var sessionsCompleted: Int = 0  // 完成的專注會話數
    @Published var uiUpdateTrigger: Int = 0  // 用於觸發 UI 更新
    
    // MARK: - AppStorage Properties
    @AppStorage("targetDateTimestamp") private var targetDateTimestamp: Double = 0
    @AppStorage("isRunningStorage") private var isRunningStorage: Bool = false
    @AppStorage("isWorkModeStorage") private var isWorkModeStorage: Bool = true
    @AppStorage("focusMinutes") var focusMinutes: Int = 25
    @AppStorage("breakMinutes") var breakMinutes: Int = 5
    @AppStorage("pausedRemainingTime") private var pausedRemainingTime: TimeInterval = 0
    @AppStorage("runningDuration") private var runningDuration: TimeInterval = 0  // 運行時的初始時長
    
    // MARK: - Private Properties
    private var timerCancellable: AnyCancellable?
    private let feedbackProvider: FeedbackProvider
    
    // MARK: - Computed Properties
    var currentDuration: TimeInterval {
        isWorkMode ? TimeInterval(focusMinutes * 60) : TimeInterval(breakMinutes * 60)
    }
    
    var totalFocusTime: TimeInterval {
        sessions
            .filter { $0.type == .focus }
            .reduce(0) { $0 + $1.duration }
    }
    
    var progress: Double {
        if isRunning, let targetDate = targetDate {
            // 運行中：使用保存的運行時長計算進度，避免設置更改影響進度條
            let totalDuration = runningDuration > 0 ? runningDuration : currentDuration
            let elapsed = totalDuration - targetDate.timeIntervalSinceNow
            return min(max(elapsed / totalDuration, 0), 1)
        } else if pausedRemainingTime > 0 {
            // 暫停時：使用保存的運行時長計算進度
            let totalDuration = runningDuration > 0 ? runningDuration : currentDuration
            let elapsed = totalDuration - pausedRemainingTime
            return min(max(elapsed / totalDuration, 0), 1)
        } else {
            // 初始狀態
            return 0
        }
    }
    
    var statusText: String {
        isWorkMode ? "工作時間" : "休息時間"
    }
    
    var buttonText: String {
        isRunning ? "暫停" : "開始"
    }
    
    /// 當前應該顯示的剩餘時間
    var displayRemainingTime: TimeInterval {
        if isRunning, let targetDate = targetDate {
            // 運行中：顯示到目標時間的剩餘時間
            return max(0, targetDate.timeIntervalSinceNow)
        } else if pausedRemainingTime > 0 {
            // 暫停時：顯示暫停時的剩餘時間
            return pausedRemainingTime
        } else {
            // 初始狀態：顯示完整時長
            return currentDuration
        }
    }
    
    // MARK: - Initialization
    init(feedbackProvider: FeedbackProvider) {
        self.feedbackProvider = feedbackProvider
        // 延迟恢复状态，避免初始化时的崩溃
        Task { @MainActor in
            self.restoreState()
            self.startTimerMonitoring()
        }
    }
    
    // AnyCancellable 会在释放时自动取消，无需手动 deinit
    
    // MARK: - Public Methods
    func startTimer() {
        // 如果已經在運行，則暫停
        if isRunning {
            pauseTimer()
            return
        }
        
        // 啟動計時器
        // 檢查是否有暫停的剩餘時間
        let duration = pausedRemainingTime > 0 ? pausedRemainingTime : currentDuration
        
        // 保存運行時的初始時長（僅在新啟動時，不在恢復暫停時）
        if pausedRemainingTime == 0 {
            runningDuration = duration
        }
        
        targetDate = Date.now.addingTimeInterval(duration)
        targetDateTimestamp = targetDate?.timeIntervalSince1970 ?? 0
        isRunning = true
        isRunningStorage = true
        pausedRemainingTime = 0  // 清除暫停時間
        
        // 請求通知權限並排程通知（iOS/macOS）
        Task {
            await feedbackProvider.scheduleCompletionNotification(in: duration, isWorkMode: isWorkMode)
        }
    }
    
    func pauseTimer() {
        // 保存剩餘時間
        if let targetDate = targetDate {
            pausedRemainingTime = max(0, targetDate.timeIntervalSinceNow)
        }
        
        isRunning = false
        isRunningStorage = false
        targetDate = nil
        targetDateTimestamp = 0
        
        // 取消通知
        Task {
            await feedbackProvider.cancelNotifications()
        }
    }
    
    func resetTimer() {
        pauseTimer()
        pausedRemainingTime = 0  // 重置時清除暫停時間
        runningDuration = 0  // 清除運行時長
        isWorkMode = true
        isWorkModeStorage = true
    }
    
    func switchMode() {
        isWorkMode.toggle()
        isWorkModeStorage = isWorkMode
    }
    
    // MARK: - Private Methods
    private func restoreState() {
        // 恢復儲存的狀態
        isWorkMode = isWorkModeStorage
        
        // 恢復目標時間
        if targetDateTimestamp > 0 {
            let restoredDate = Date(timeIntervalSince1970: targetDateTimestamp)
            // 檢查是否已經過期
            if restoredDate > Date.now {
                targetDate = restoredDate
                isRunning = isRunningStorage
            } else {
                // 計時器已過期，重置狀態
                isRunning = false
                isRunningStorage = false
                targetDate = nil
                targetDateTimestamp = 0
            }
        } else {
            isRunning = false
        }
    }
    
    private func startTimerMonitoring() {
        // 每 0.1 秒檢查一次計時器是否完成，並更新 UI
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.checkTimerCompletion()
                // 觸發 UI 更新（每秒更新一次以優化性能）
                if self.isRunning {
                    self.uiUpdateTrigger += 1
                }
            }
    }
    
    private func checkTimerCompletion() {
        guard isRunning, let targetDate = targetDate else { return }
        
        if Date.now >= targetDate {
            completeTimer()
        }
    }
    
    private func completeTimer() {
        // 記錄完成的會話（使用實際運行的時長）
        let completedSession = Session(
            type: isWorkMode ? .focus : .break,
            duration: runningDuration > 0 ? runningDuration : currentDuration,
            timestamp: Date()
        )
        sessions.append(completedSession)
        
        // 如果是工作會話，增加計數
        if isWorkMode {
            sessionsCompleted += 1
        }
        
        // 計時器完成
        isRunning = false
        isRunningStorage = false
        targetDate = nil
        targetDateTimestamp = 0
        pausedRemainingTime = 0  // 清除暫停時間
        runningDuration = 0  // 清除運行時長
        
        // 觸發平台特定的反饋
        Task {
            await feedbackProvider.triggerCompletion(isWorkMode: isWorkMode)
        }
        
        // 自動切換模式
        isWorkMode.toggle()
        isWorkModeStorage = isWorkMode
        
        // 自動開始下一個週期（可選，註解掉則不自動開始）
        // startTimer()
    }
    
    // MARK: - Settings Methods
    func updateSettings(focusMinutes: Int, breakMinutes: Int) {
        self.focusMinutes = focusMinutes
        self.breakMinutes = breakMinutes
        // 清除暫停的剩餘時間，以便使用新的設定
        if !isRunning {
            pausedRemainingTime = 0
        }
    }
}
