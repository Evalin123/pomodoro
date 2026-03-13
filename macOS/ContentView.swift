//
//  ContentView.swift
//  Pomodoro (macOS) - Nature Organic
//
//  Created on 2026/3/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: NotificationManager.shared)
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // 有機背景
            DesignSystem.Colors.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                Spacer()
                
                // 狀態標籤
                statusBadge
                
                // 計時器顯示
                timerDisplay
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                Spacer()
                
                // 控制按鈕
                controlButtons
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                
                Spacer()
            }
            .padding(.vertical, DesignSystem.Spacing.xl)
        }
        .frame(minWidth: 400, idealWidth: 450, minHeight: 350, idealHeight: 400)
        .onAppear {
            NotificationManager.shared.clearBadge()
            withAnimation(DesignSystem.animationNormal.repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
        .onDisappear {
            // 在 view 消失时暂停动画
            pulseAnimation = false
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode)
                .frame(width: 10, height: 10)
                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
            
            Text(viewModel.statusText)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .organicCard(color: DesignSystem.Colors.bgSecondary)
    }
    
    // MARK: - Timer Display
    private var timerDisplay: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let targetDate = viewModel.targetDate, viewModel.isRunning {
                Text(targetDate, style: .timer)
                    .font(.system(size: 64, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode,
                                viewModel.isWorkMode ? DesignSystem.Colors.brandAccent : DesignSystem.Colors.brandSecondary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                Text(formatTime(viewModel.currentDuration))
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Colors.textMuted)
            }
            
            if viewModel.isRunning {
                ProgressView()
                    .tint(viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode)
                    .scaleEffect(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .organicCard()
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 開始/暫停按鈕
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.startTimer()
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    Text(viewModel.buttonText)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                        .fill(
                            LinearGradient(
                                colors: viewModel.isRunning ?
                                    [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.8)] :
                                    [DesignSystem.Colors.brandPrimary, DesignSystem.Colors.brandAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .organicShadow(level: 2)
            }
            .buttonStyle(.plain)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                // 重置按鈕
                Button(action: {
                    withAnimation(DesignSystem.animationFast) {
                        viewModel.resetTimer()
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重置")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .organicCard(color: .white)
                }
                .buttonStyle(.plain)
                
                // 切換模式按鈕
                Button(action: {
                    withAnimation(DesignSystem.animationFast) {
                        viewModel.switchMode()
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: viewModel.isWorkMode ? "cup.and.saucer.fill" : "briefcase.fill")
                        Text(viewModel.isWorkMode ? "休息" : "工作")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                            .fill(viewModel.isWorkMode ? DesignSystem.Colors.restMode : DesignSystem.Colors.workMode)
                    )
                    .organicShadow()
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isRunning)
                .opacity(viewModel.isRunning ? 0.5 : 1.0)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
