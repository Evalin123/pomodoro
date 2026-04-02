//
//  HapticManager.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/12.
//

import Foundation
import WatchKit
import os.log

/// watchOS 的觸覺回饋管理器
/// 實現 FeedbackProvider 協議
@MainActor
class HapticManager: FeedbackProvider {
    static let shared = HapticManager()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.pomodoro", category: "Haptic")
    
    private init() {}
    
    // MARK: - FeedbackProvider Implementation
    
    func triggerCompletion(isWorkMode: Bool) async {
        WKInterfaceDevice.current().play(.notification)
        
        Self.logger.info("計時器完成：\(isWorkMode ? "工作" : "休息")時間結束")
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        WKInterfaceDevice.current().play(.notification)
    }
    
    func scheduleCompletionNotification(in timeInterval: TimeInterval, isWorkMode: Bool) async {
        // watchOS 不使用通知，將使用觸覺回饋
    }
    
    func cancelNotifications() async {
        // watchOS 不使用通知，此方法為空實作
    }
    
    // MARK: - Additional Haptic Methods
    
    /// 播放點擊觸覺回饋
    func playClick() {
        WKInterfaceDevice.current().play(.click)
    }
}
