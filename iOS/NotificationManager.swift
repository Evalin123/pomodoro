//
//  NotificationManager.swift
//  Pomodoro (iOS & macOS)
//
//  Created on 2026/3/12.
//

import Foundation
import UserNotifications
import os.log

/// iOS 和 macOS 的通知管理器
/// 實現 FeedbackProvider 協議
@MainActor
class NotificationManager: FeedbackProvider {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.pomodoro", category: "Notification")
    
    private init() {}
    
    // MARK: - Permission
    
    /// 請求通知權限
    func requestPermission() async -> Bool {
        // 先檢查當前權限狀態
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .denied:
            Self.logger.warning("通知權限已被拒絕。請在系統設定中啟用通知。")
            return false
        case .notDetermined:
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    Self.logger.info("通知權限已授予")
                } else {
                    Self.logger.warning("用戶拒絕了通知權限")
                }
                return granted
            } catch {
                Self.logger.error("通知權限請求失敗: \(error.localizedDescription)")
                return false
            }
        case .ephemeral:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - FeedbackProvider Implementation
    
    func triggerCompletion(isWorkMode: Bool) async {
        Self.logger.info("計時器完成：\(isWorkMode ? "工作" : "休息")時間結束")
    }
    
    func scheduleCompletionNotification(in timeInterval: TimeInterval, isWorkMode: Bool) async {
        // 請求權限（如果尚未請求），但不阻塞計時器
        let granted = await requestPermission()
        guard granted else {
            Self.logger.warning("通知權限未授予，計時器將繼續運行但不會顯示通知")
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
            Self.logger.info("通知已排程：\(Int(timeInterval)) 秒後")
        } catch {
            Self.logger.error("排程通知失敗: \(error.localizedDescription)")
        }
    }
    
    func cancelNotifications() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["pomodoroCompletion"])
        Self.logger.info("已取消待處理的通知")
    }
    
    // MARK: - Badge Management
    
    /// 清除角標
    func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }
}
