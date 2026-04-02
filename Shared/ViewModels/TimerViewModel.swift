//
//  TimerViewModel.swift
//  Pomodoro
//
//  Created on 2026/3/12.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Session Mode
enum SessionMode: String, Codable {
    case work
    case shortBreak
    case longBreak
}

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
    @Published var sessionMode: SessionMode = .work
    @Published var targetDate: Date?
    @Published var sessions: [Session] = []  // 會話歷史
    @Published var sessionsCompleted: Int = 0  // 完成的專注會話數
    @Published var uiUpdateTrigger: Int = 0  // 用於觸發 UI 更新
    
    // MARK: - Persistence Keys
    private static let sessionsKey = "savedSessions"
    private static let sessionsCompletedKey = "sessionsCompletedCount"
    
    // MARK: - AppStorage Properties
    @AppStorage("targetDateTimestamp") private var targetDateTimestamp: Double = 0
    @AppStorage("isRunningStorage") private var isRunningStorage: Bool = false
    @AppStorage("sessionModeStorage") private var sessionModeStorage: String = SessionMode.work.rawValue
    @AppStorage("focusMinutes") var focusMinutes: Int = 25
    @AppStorage("breakMinutes") var breakMinutes: Int = 5
    @AppStorage("longBreakMinutes") var longBreakMinutes: Int = 15
    @AppStorage("pausedRemainingTime") private var pausedRemainingTime: TimeInterval = 0
    @AppStorage("runningDuration") private var runningDuration: TimeInterval = 0  // 運行時的初始時長
    
    // MARK: - Private Properties
    private var timerCancellable: AnyCancellable?
    private let feedbackProvider: FeedbackProvider
    
    // MARK: - Computed Properties
    var currentDuration: TimeInterval {
        switch sessionMode {
        case .work:
            return TimeInterval(focusMinutes * 60)
        case .shortBreak:
            return TimeInterval(breakMinutes * 60)
        case .longBreak:
            return TimeInterval(longBreakMinutes * 60)
        }
    }
    
    var currentMinutes: Int {
        switch sessionMode {
        case .work:
            return focusMinutes
        case .shortBreak:
            return breakMinutes
        case .longBreak:
            return longBreakMinutes
        }
    }
    
    var minAllowedMinutes: Int {
        if !isRunning && pausedRemainingTime == 0 {
            return 1  // 完全未開始時可以自由調整
        }
        // 運行中或暫停時只能增加，不能減少
        return currentMinutes
    }
    
    var isWorkMode: Bool {
        sessionMode == .work
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
        switch sessionMode {
        case .work:
            return "工作時間"
        case .shortBreak:
            return "短休息"
        case .longBreak:
            return "長休息"
        }
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
            self.loadSessions()
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
        sessionMode = .work
        sessionModeStorage = SessionMode.work.rawValue
    }
    
    // MARK: - Private Methods
    private func restoreState() {
        // 恢復 sessionMode
        if let mode = SessionMode(rawValue: sessionModeStorage) {
            sessionMode = mode
        }
        
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
                // 觸發 UI 更新
                if self.isRunning {
                    self.uiUpdateTrigger &+= 1
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
            type: sessionMode == .work ? .focus : .break,
            duration: runningDuration > 0 ? runningDuration : currentDuration,
            timestamp: Date()
        )
        sessions.append(completedSession)
        saveSessions()
        
        // 如果是工作會話，增加計數
        if sessionMode == .work {
            sessionsCompleted += 1
        }
        
        // 計時器完成
        isRunning = false
        isRunningStorage = false
        targetDate = nil
        targetDateTimestamp = 0
        pausedRemainingTime = 0  // 清除暫停時間
        runningDuration = 0  // 清除運行時長
        
        // 觸發平台特定的反饋（先捕獲當前模式，避免 Task 執行時 sessionMode 已切換）
        let wasWorkMode = sessionMode == .work
        Task {
            await feedbackProvider.triggerCompletion(isWorkMode: wasWorkMode)
        }
        
        // 自動切換模式
        if sessionMode == .work {
            // 工作完成後，判斷進入小休息還是大休息
            if sessionsCompleted % 4 == 0 {
                // 每 4 個工作後進入大休息
                sessionMode = .longBreak
            } else {
                sessionMode = .shortBreak
            }
        } else if sessionMode == .longBreak {
            // 大休息結束，進入工作（不重置 sessionsCompleted，保留每日統計）
            sessionMode = .work
        } else {
            // 小休息結束，進入工作
            sessionMode = .work
        }
        
        sessionModeStorage = sessionMode.rawValue
        
        // 自動開始下一個週期（可選，註解掉則不自動開始）
        // startTimer()
    }
    
    // MARK: - Persistence Methods
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: Self.sessionsKey)
        }
        UserDefaults.standard.set(sessionsCompleted, forKey: Self.sessionsCompletedKey)
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: Self.sessionsKey),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            // 只保留當天的紀錄
            let calendar = Calendar.current
            sessions = decoded.filter { calendar.isDateInToday($0.timestamp) }
            // 如果有過期資料被過濾掉，立即更新持久化
            if sessions.count != decoded.count {
                saveSessions()
            }
        }
        // sessionsCompleted 也只計算當天的專注會話數
        sessionsCompleted = sessions.filter { $0.type == .focus }.count
    }
    
    // MARK: - Settings Methods
    @discardableResult
    func updateSettings(focusMinutes: Int? = nil, breakMinutes: Int? = nil, longBreakMinutes: Int? = nil) -> Bool {
        // 檢查是否嘗試減少運行中或暫停時的時間
        if isRunning || pausedRemainingTime > 0 {
            switch sessionMode {
            case .work:
                if let newFocus = focusMinutes, newFocus < self.focusMinutes {
                    return false  // 不允許減少
                }
            case .shortBreak:
                if let newBreak = breakMinutes, newBreak < self.breakMinutes {
                    return false
                }
            case .longBreak:
                if let newLong = longBreakMinutes, newLong < self.longBreakMinutes {
                    return false
                }
            }
        }
        
        // 更新設定
        if let newFocus = focusMinutes {
            self.focusMinutes = newFocus
        }
        if let newBreak = breakMinutes {
            self.breakMinutes = newBreak
        }
        if let newLong = longBreakMinutes {
            self.longBreakMinutes = newLong
        }
        
        // 如果運行中，需要調整 targetDate 和 runningDuration
        if isRunning, let targetDate = targetDate {
            let remaining = max(0, targetDate.timeIntervalSinceNow)
            let newDuration = currentDuration
            let newTargetDate = Date.now.addingTimeInterval(remaining + (newDuration - runningDuration))
            self.targetDate = newTargetDate
            self.targetDateTimestamp = newTargetDate.timeIntervalSince1970
            self.runningDuration = newDuration
        } else if pausedRemainingTime > 0 {
            // 如果暫停中，調整暫停的剩餘時間和運行時長
            let oldDuration = runningDuration > 0 ? runningDuration : currentDuration
            let newDuration = currentDuration
            let difference = newDuration - oldDuration
            pausedRemainingTime = max(0, pausedRemainingTime + difference)
            runningDuration = newDuration
        } else {
            // 完全未開始，清除暫停時間
            pausedRemainingTime = 0
        }
        
        return true  // 允許更新
    }
}
