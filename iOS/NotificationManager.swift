//
//  NotificationManager.swift
//  Pomodoro (iOS & macOS)
//
//  Created on 2026/3/12.
//

import Foundation
import UserNotifications

/// iOS 和 macOS 的通知管理器
/// 實現 FeedbackProvider 協議
@MainActor
class NotificationManager: FeedbackProvider {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var hasRequestedPermission = false
    
    private init() {}
    
    // MARK: - Permission
    
    /// 請求通知權限
    func requestPermission() async -> Bool {
        guard !hasRequestedPermission else { return true }
        
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            hasRequestedPermission = true
            return granted
        } catch {
            print("通知權限請求失敗: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - FeedbackProvider Implementation
    
    func triggerCompletion(isWorkMode: Bool) async {
        // 在完成時不需要額外操作，通知已經在之前排程
        // 這裡可以加入額外的音效或其他反饋
        print("計時器完成：\(isWorkMode ? "工作" : "休息")時間結束")
    }
    
    func scheduleCompletionNotification(in timeInterval: TimeInterval, isWorkMode: Bool) async {
        // 請求權限（如果尚未請求）
        let granted = await requestPermission()
        guard granted else {
            print("通知權限未授予")
            return
        }
        
        // 創建通知內容
        let content = UNMutableNotificationContent()
        content.title = isWorkMode ? "工作時間結束！" : "休息時間結束！"
        content.body = isWorkMode ? "該休息一下了 ☕️" : "準備好開始工作了嗎？💪"
        content.sound = .default
        content.badge = 1
        
        // 創建觸發器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // 創建請求
        let identifier = "pomodoroCompletion"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 排程通知
        do {
            try await notificationCenter.add(request)
            print("通知已排程：\(timeInterval) 秒後")
        } catch {
            print("排程通知失敗: \(error.localizedDescription)")
        }
    }
    
    func cancelNotifications() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["pomodoroCompletion"])
        print("已取消待處理的通知")
    }
    
    // MARK: - Badge Management
    
    /// 清除角標
    func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }
}
