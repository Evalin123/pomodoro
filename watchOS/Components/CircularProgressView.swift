//
//  CircularProgressView.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/19.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let minutes: Int
    let seconds: Int
    let isWorkMode: Bool
    let isRunning: Bool
    
    private let circleSize: CGFloat = 140
    private let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color(hex: "E2E8F0").opacity(0.5),
                    lineWidth: lineWidth
                )
                .frame(width: circleSize, height: circleSize)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: isRunning ? progress : 0)
                .stroke(
                    isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .rotationEffect(.degrees(-90))
                .animation(DesignSystem.animationSlow, value: progress)
                .progressGlow(
                    color: isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode,
                    isActive: isRunning
                )
            
            // Time display
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    Text(String(format: "%02d", minutes))
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(":")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(DesignSystem.Colors.textPrimary.opacity(0.8))
                        .opacity(isRunning ? 1.0 : 0.5)
                    
                    Text(String(format: "%02d", seconds))
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                .monospacedDigit()
            }
        }
        .frame(width: circleSize, height: circleSize)
    }
}

#Preview {
    CircularProgressView(
        progress: 0.65,
        minutes: 24,
        seconds: 57,
        isWorkMode: true,
        isRunning: true
    )
}
