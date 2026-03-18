//
//  MenuBarView.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct MenuBarView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            // Logo and title
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Logo with gradient
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.restMode,
                                    DesignSystem.Colors.restMode.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .organicShadow()
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                }
                
                Text("Pomodoro Timer")
                    .font(.system(size: DesignSystem.FontSize.lg, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
            
            // Settings button
            Button(action: {
                withAnimation(DesignSystem.animationNormal) {
                    showSettings.toggle()
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                    
                    Text("Settings")
                        .font(.system(size: DesignSystem.FontSize.sm, weight: .medium))
                }
                .foregroundStyle(showSettings ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textMuted)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                        .fill(showSettings ? Color.white : Color.clear)
                        .organicShadow()
                        .opacity(showSettings ? 1 : 0)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(DesignSystem.Colors.borderSubtle)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        MenuBarView(showSettings: .constant(false))
        MenuBarView(showSettings: .constant(true))
        Spacer()
    }
    .background(DesignSystem.Colors.bgPrimary)
}
