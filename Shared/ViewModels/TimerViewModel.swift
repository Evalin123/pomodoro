//
//  TimerViewModel.swift
//  Pomodoro
//
//  Created on 2026/3/12.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning: Bool = false
    @Published var isWorkMode: Bool = true
    @Published var targetDate: Date?
    
    // MARK: - AppStorage Properties
    @AppStorage("targetDateTimestamp") private var targetDateTimestamp: Double = 0
    @AppStorage("isRunningStorage") private var isRunningStorage: Bool = false
    @AppStorage("isWorkModeStorage") private var isWorkModeStorage: Bool = true
    
    // MARK: - Constants
    private let workDuration: TimeInterval = 25 * 60 // 25 分鐘
    private let breakDuration: TimeInterval = 5 * 60 // 5 分鐘
    
    // MARK: - Private Properties
    private var timerCancellable: AnyCancellable?
    private let feedbackProvider: FeedbackProvider
    
    // MARK: - Computed Properties
    var currentDuration: TimeInterval {
        isWorkMode ? workDuration : breakDuration
    }
    
    var statusText: String {
        isWorkMode ? "工作時間" : "休息時間"
    }
    
    var buttonText: String {
        isRunning ? "暫停" : "開始"
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
        let duration = currentDuration
        targetDate = Date.now.addingTimeInterval(duration)
        targetDateTimestamp = targetDate?.timeIntervalSince1970 ?? 0
        isRunning = true
        isRunningStorage = true
        
        // 請求通知權限並排程通知（iOS/macOS）
        Task {
            await feedbackProvider.scheduleCompletionNotification(in: duration, isWorkMode: isWorkMode)
        }
    }
    
    func pauseTimer() {
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
        // 每 0.1 秒檢查一次計時器是否完成
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTimerCompletion()
            }
    }
    
    private func checkTimerCompletion() {
        guard isRunning, let targetDate = targetDate else { return }
        
        if Date.now >= targetDate {
            completeTimer()
        }
    }
    
    private func completeTimer() {
        // 計時器完成
        isRunning = false
        isRunningStorage = false
        targetDate = nil
        targetDateTimestamp = 0
        
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
}
