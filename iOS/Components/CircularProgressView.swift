//
//  CircularProgressView.swift
//  Pomodoro (iOS)
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
    
    private let lineWidth: CGFloat = 10
    private let radius: CGFloat = 132  // iOS 使用較小的半徑
    
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
            VStack(spacing: 4) {
                Text(formatTime(minutes: minutes, seconds: seconds))
                    .font(.system(size: 56, weight: .light, design: .rounded))
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
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.textMuted)
                    .textCase(.uppercase)
                    .tracking(1)
            }
        }
        .frame(width: radius * 2 + 20, height: radius * 2 + 20)
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
            subtitle: "Deep Work"
        )
        
        CircularProgressView(
            progress: 0.3,
            minutes: 3,
            seconds: 45,
            isWorkMode: false,
            isRunning: true,
            subtitle: "Relax & Breathe"
        )
    }
    .padding()
    .background(DesignSystem.Colors.bgPrimary)
}
