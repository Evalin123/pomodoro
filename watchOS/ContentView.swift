//
//  ContentView.swift
//  Pomodoro (watchOS) - Nature Organic
//
//  Created on 2026/3/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: HapticManager.shared)
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // 有機背景
            DesignSystem.Colors.bgPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 6) {
                // 狀態標籤
                statusBadge
                
                // 計時器顯示
                timerDisplay
                
                // 控制按鈕
                controlButtons
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .onAppear {
            withAnimation(DesignSystem.animationNormal.repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
        .onDisappear {
            // 在 view 消失时暂停动画，避免后台继续运行
            pulseAnimation = false
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode)
                .frame(width: 6, height: 6)
                .scaleEffect(pulseAnimation ? 1.4 : 1.0)
            
            Text(viewModel.statusText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.bgSecondary)
                .organicShadow()
        )
    }
    
    // MARK: - Timer Display
    private var timerDisplay: some View {
        VStack(spacing: 4) {
            if let targetDate = viewModel.targetDate, viewModel.isRunning {
                Text(targetDate, style: .timer)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(
                        viewModel.isWorkMode ? 
                            DesignSystem.Colors.workMode : 
                            DesignSystem.Colors.restMode
                    )
            } else {
                Text(formatTime(viewModel.currentDuration))
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Colors.textMuted)
            }
            
            if viewModel.isRunning {
                ProgressView()
                    .tint(viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode)
                    .scaleEffect(0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .fill(DesignSystem.Colors.bgSecondary)
                .organicShadow()
        )
        .padding(.horizontal, 8)
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        VStack(spacing: 6) {
            // 開始/暫停按鈕
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.startTimer()
                }
                if viewModel.isRunning {
                    HapticManager.shared.playStop()
                } else {
                    HapticManager.shared.playStart()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 10))
                    Text(viewModel.buttonText)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                        .fill(
                            viewModel.isRunning ?
                                DesignSystem.Colors.warning :
                                DesignSystem.Colors.brandPrimary
                        )
                )
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 6) {
                // 重置按鈕
                Button(action: {
                    withAnimation(DesignSystem.animationFast) {
                        viewModel.resetTimer()
                    }
                    HapticManager.shared.playClick()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                .fill(.white)
                                .organicShadow()
                        )
                }
                .buttonStyle(.plain)
                
                // 切換模式按鈕
                Button(action: {
                    withAnimation(DesignSystem.animationFast) {
                        viewModel.switchMode()
                    }
                    HapticManager.shared.playClick()
                }) {
                    Image(systemName: viewModel.isWorkMode ? "cup.and.saucer.fill" : "briefcase.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                .fill(viewModel.isWorkMode ? DesignSystem.Colors.restMode : DesignSystem.Colors.workMode)
                        )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isRunning)
                .opacity(viewModel.isRunning ? 0.5 : 1.0)
            }
        }
        .padding(.horizontal, 8)
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
