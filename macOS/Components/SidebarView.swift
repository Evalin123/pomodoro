//
//  SidebarView.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Binding var showSettings: Bool
    
    @State private var tempFocusMinutes: Double
    @State private var tempBreakMinutes: Double
    @State private var tempLongBreakMinutes: Double
    
    init(viewModel: TimerViewModel, showSettings: Binding<Bool>) {
        self.viewModel = viewModel
        self._showSettings = showSettings
        self._tempFocusMinutes = State(initialValue: Double(viewModel.focusMinutes))
        self._tempBreakMinutes = State(initialValue: Double(viewModel.breakMinutes))
        self._tempLongBreakMinutes = State(initialValue: Double(viewModel.longBreakMinutes))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                settingsView
            } else {
                statsView
            }
        }
        .frame(width: 420)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(DesignSystem.Colors.borderSubtle)
                .frame(width: 1),
            alignment: .leading
        )
        .onChange(of: showSettings) { _, isShowing in
            if isShowing {
                tempFocusMinutes = Double(viewModel.focusMinutes)
                tempBreakMinutes = Double(viewModel.breakMinutes)
                tempLongBreakMinutes = Double(viewModel.longBreakMinutes)
            }
        }
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Today's Stats")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.md)
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Sessions completed
                    StatsCardView(
                        icon: "target",
                        value: "\(viewModel.sessionsCompleted)",
                        label: "Sessions completed",
                        color: DesignSystem.Colors.workMode
                    )
                    
                    // Focus time
                    StatsCardView(
                        icon: "clock.fill",
                        value: formatFocusTime(viewModel.totalFocusTime),
                        label: "Focus time",
                        color: DesignSystem.Colors.brandAccent
                    )
                    
                    // Streak
                    StatsCardView(
                        icon: "flame.fill",
                        value: viewModel.sessionsCompleted > 0 ? "🔥" : "—",
                        label: "Current streak",
                        color: DesignSystem.Colors.restMode
                    )
                }
                .padding(DesignSystem.Spacing.lg)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Settings View
    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Timer Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.md)
            
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    // Focus duration
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Focus Duration")
                            .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Slider(value: $tempFocusMinutes, in: 1...60, step: 1)
                                .tint(DesignSystem.Colors.restMode)
                            
                            Text("\(Int(tempFocusMinutes)) min")
                                .font(.system(size: DesignSystem.FontSize.base, weight: .medium, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .frame(width: 64, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    
                    // Break duration
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Break Duration")
                            .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Slider(value: $tempBreakMinutes, in: 1...30, step: 1)
                                .tint(DesignSystem.Colors.restMode)
                            
                            Text("\(Int(tempBreakMinutes)) min")
                                .font(.system(size: DesignSystem.FontSize.base, weight: .medium, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .frame(width: 64, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    
                    // Long break duration
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Long Break Duration")
                            .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Slider(value: $tempLongBreakMinutes, in: 1...60, step: 1)
                                .tint(DesignSystem.Colors.brandAccent)
                            
                            Text("\(Int(tempLongBreakMinutes)) min")
                                .font(.system(size: DesignSystem.FontSize.base, weight: .medium, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .frame(width: 64, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                    
                    // Save button
                    Button(action: saveSettings) {
                        Text("Save Changes")
                            .font(.system(size: DesignSystem.FontSize.base, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                                    .fill(
                                        LinearGradient(
                                            colors: isSaveEnabled ? [
                                                DesignSystem.Colors.restMode,
                                                DesignSystem.Colors.restMode.opacity(0.8)
                                            ] : [
                                                DesignSystem.Colors.textMuted.opacity(0.3),
                                                DesignSystem.Colors.textMuted.opacity(0.2)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .organicShadow(level: isSaveEnabled ? 2 : 0)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isSaveEnabled)

                }
                .padding(DesignSystem.Spacing.lg)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    /// 計時器是否已啟動（運行中或暫停）
    private var isTimerActive: Bool {
        viewModel.isRunning || viewModel.pausedRemainingTime > 0
    }
    
    /// 基準時間（當前模式的分鐘數）
    private var savedMinutes: Int {
        if isTimerActive {
            // 計時器啟動時，基準是運行時的時長
            let savedDuration = viewModel.runningDuration > 0 ? viewModel.runningDuration : viewModel.currentDuration
            return Int(savedDuration) / 60
        } else {
            // 未啟動時，基準是當前設定
            return viewModel.currentMinutes
        }
    }
    
    /// Save Changes 按鈕是否啟用
    private var isSaveEnabled: Bool {
        let draftMinutes: Int
        let currentSavedMinutes: Int
        
        switch viewModel.sessionMode {
        case .work:
            draftMinutes = Int(tempFocusMinutes)
            currentSavedMinutes = viewModel.focusMinutes
        case .shortBreak:
            draftMinutes = Int(tempBreakMinutes)
            currentSavedMinutes = viewModel.breakMinutes
        case .longBreak:
            draftMinutes = Int(tempLongBreakMinutes)
            currentSavedMinutes = viewModel.longBreakMinutes
        }
        
        if isTimerActive {
            // 計時器已啟動：只有草稿大於基準才啟用
            return draftMinutes > savedMinutes
        } else {
            // 計時器未啟動：只要有變更就啟用
            return draftMinutes != currentSavedMinutes
        }
    }
    
    private func formatFocusTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func saveSettings() {
        viewModel.updateSettings(
            focusMinutes: Int(tempFocusMinutes),
            breakMinutes: Int(tempBreakMinutes),
            longBreakMinutes: Int(tempLongBreakMinutes)
        )
        withAnimation(DesignSystem.animationNormal) {
            showSettings = false
        }
    }
}

#Preview {
    HStack(spacing: 0) {
        Rectangle()
            .fill(DesignSystem.Colors.bgPrimary)
        
        SidebarView(
            viewModel: TimerViewModel(feedbackProvider: NotificationManager.shared),
            showSettings: .constant(false)
        )
    }
    .frame(height: 600)
}
