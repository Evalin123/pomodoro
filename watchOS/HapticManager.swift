//
//  HapticManager.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/12.
//

import Foundation
import WatchKit

/// watchOS 的觸覺回饋管理器
/// 實現 FeedbackProvider 協議
@MainActor
class HapticManager: FeedbackProvider {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - FeedbackProvider Implementation
    
    func triggerCompletion(isWorkMode: Bool) async {
        // 觸發強力震動通知
        WKInterfaceDevice.current().play(.notification)
        
        print("計時器完成：\(isWorkMode ? "工作" : "休息")時間結束")
        
        // 可選：再次震動以加強提醒
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 秒
        WKInterfaceDevice.current().play(.notification)
    }
    
    func scheduleCompletionNotification(in timeInterval: TimeInterval, isWorkMode: Bool) async {
        // watchOS 不使用通知，此方法為空實作
        print("watchOS 不排程通知，將使用觸覺回饋")
    }
    
    func cancelNotifications() async {
        // watchOS 不使用通知，此方法為空實作
    }
    
    // MARK: - Additional Haptic Methods
    
    /// 播放開始觸覺回饋
    func playStart() {
        WKInterfaceDevice.current().play(.start)
    }
    
    /// 播放停止觸覺回饋
    func playStop() {
        WKInterfaceDevice.current().play(.stop)
    }
    
    /// 播放點擊觸覺回饋
    func playClick() {
        WKInterfaceDevice.current().play(.click)
    }
}
