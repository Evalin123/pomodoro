//
//  SettingsView.swift
//  Pomodoro (iOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFocusMinutes: Double
    @State private var tempBreakMinutes: Double
    @State private var tempLongBreakMinutes: Double
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        self._tempFocusMinutes = State(initialValue: Double(viewModel.focusMinutes))
        self._tempBreakMinutes = State(initialValue: Double(viewModel.breakMinutes))
        self._tempLongBreakMinutes = State(initialValue: Double(viewModel.longBreakMinutes))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Timer Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.sm)
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Focus Duration
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Focus Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DesignSystem.Colors.textMuted)
                            
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("\(Int(tempFocusMinutes))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(DesignSystem.Colors.workMode)
                                        .monospacedDigit()
                                    
                                    Text("min")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(DesignSystem.Colors.textMuted)
                                }
                                
                                Slider(value: $tempFocusMinutes, in: 1...60, step: 1)
                                    .tint(DesignSystem.Colors.workMode)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                    .fill(.white.opacity(0.7))
                                    .organicShadow()
                            )
                        }
                        
                        // Break Duration
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Break Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DesignSystem.Colors.textMuted)
                            
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("\(Int(tempBreakMinutes))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(DesignSystem.Colors.restMode)
                                        .monospacedDigit()
                                    
                                    Text("min")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(DesignSystem.Colors.textMuted)
                                }
                                
                                Slider(value: $tempBreakMinutes, in: 1...30, step: 1)
                                    .tint(DesignSystem.Colors.restMode)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                    .fill(.white.opacity(0.7))
                                    .organicShadow()
                            )
                        }
                        
                        // Long Break Duration
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Long Break Duration")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(DesignSystem.Colors.textMuted)
                            
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack {
                                    Text("\(Int(tempLongBreakMinutes))")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(DesignSystem.Colors.brandAccent)
                                        .monospacedDigit()
                                    
                                    Text("min")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(DesignSystem.Colors.textMuted)
                                }
                                
                                Slider(value: $tempLongBreakMinutes, in: 1...60, step: 1)
                                    .tint(DesignSystem.Colors.brandAccent)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                    .fill(.white.opacity(0.7))
                                    .organicShadow()
                            )
                        }
                        
                        // Save button
                        Button(action: saveSettings) {
                            Text("Save Changes")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
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
                                )
                                .organicShadow(level: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, DesignSystem.Spacing.md)
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
        }
        .appBackgroundGradient()
        .navigationBarHidden(true)
    }
    
    private func saveSettings() {
        viewModel.updateSettings(
            focusMinutes: Int(tempFocusMinutes),
            breakMinutes: Int(tempBreakMinutes),
            longBreakMinutes: Int(tempLongBreakMinutes)
        )
        dismiss()
    }
}

#Preview {
    SettingsView(viewModel: TimerViewModel(feedbackProvider: NotificationManager.shared))
}
