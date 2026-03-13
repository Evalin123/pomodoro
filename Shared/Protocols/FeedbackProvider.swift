//
//  FeedbackProvider.swift
//  Pomodoro
//
//  Created on 2026/3/12.
//

import Foundation

/// 平台特定的反饋提供者協議
/// iOS/macOS 使用本地通知，watchOS 使用觸覺回饋
protocol FeedbackProvider: Sendable {
    /// 觸發完成反饋
    func triggerCompletion(isWorkMode: Bool) async
    
    /// 排程完成通知（iOS/macOS）
    func scheduleCompletionNotification(in timeInterval: TimeInterval, isWorkMode: Bool) async
    
    /// 取消所有待處理的通知
    func cancelNotifications() async
}
