//
//  StatsCardView.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct StatsCardView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(color)
            }
            
            // Value and label
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(label)
                    .font(.system(size: DesignSystem.FontSize.sm, weight: .regular))
                    .foregroundStyle(DesignSystem.Colors.textMuted)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        StatsCardView(
            icon: "target",
            value: "8",
            label: "Sessions completed",
            color: DesignSystem.Colors.workMode
        )
        
        StatsCardView(
            icon: "clock.fill",
            value: "3h 20m",
            label: "Focus time",
            color: DesignSystem.Colors.brandAccent
        )
        
        StatsCardView(
            icon: "flame.fill",
            value: "🔥",
            label: "Current streak",
            color: DesignSystem.Colors.restMode
        )
    }
    .padding()
    .frame(width: 420)
    .background(DesignSystem.Colors.bgPrimary)
}
