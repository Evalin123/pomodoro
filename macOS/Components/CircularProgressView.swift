//
//  CircularProgressView.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let minutes: Int
    let seconds: Int
    let isWorkMode: Bool
    let isRunning: Bool
    let subtitle: String
    
    private let lineWidth: CGFloat = 14
    private let radius: CGFloat = 176
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    DesignSystem.Colors.borderSubtle,
                    lineWidth: lineWidth
                )
                .frame(width: radius * 2, height: radius * 2)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90))
                .progressGlow(color: progressColor, isActive: isRunning)
                .animation(DesignSystem.animationSlow, value: progress)
            
            // Time display
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(formatTime(minutes: minutes, seconds: seconds))
                    .font(.system(size: DesignSystem.FontSize.huge, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(
                        isRunning ?
                            LinearGradient(
                                colors: [progressColor, progressColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [DesignSystem.Colors.textMuted, DesignSystem.Colors.textMuted],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                
                Text(subtitle)
                    .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.textMuted)
            }
        }
        .frame(width: radius * 2 + 40, height: radius * 2 + 40)
    }
    
    private var progressColor: Color {
        isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode
    }
    
    private func formatTime(minutes: Int, seconds: Int) -> String {
        String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 40) {
        CircularProgressView(
            progress: 0.65,
            minutes: 16,
            seconds: 30,
            isWorkMode: true,
            isRunning: true,
            subtitle: "Stay focused on your task"
        )
        
        CircularProgressView(
            progress: 0.3,
            minutes: 3,
            seconds: 45,
            isWorkMode: false,
            isRunning: true,
            subtitle: "Relax and recharge"
        )
    }
    .padding()
    .background(DesignSystem.Colors.bgPrimary)
}
