//
//  SettingsView.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/19.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFocusMinutes: Double
    @State private var tempBreakMinutes: Double
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        self._tempFocusMinutes = State(initialValue: Double(viewModel.focusMinutes))
        self._tempBreakMinutes = State(initialValue: Double(viewModel.breakMinutes))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                
                // Focus slider
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("FOCUS")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        
                        Spacer()
                        
                        Text("\(Int(tempFocusMinutes))m")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.workMode)
                    }
                    
                    Slider(value: $tempFocusMinutes, in: 1...60, step: 1)
                        .tint(DesignSystem.Colors.workMode)
                }
                .padding(DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                        .fill(.white.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                )
                
                // Break slider
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text("BREAK")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        
                        Spacer()
                        
                        Text("\(Int(tempBreakMinutes))m")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.restMode)
                    }
                    
                    Slider(value: $tempBreakMinutes, in: 1...30, step: 1)
                        .tint(DesignSystem.Colors.restMode)
                }
                .padding(DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                        .fill(.white.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                )
                
                // Save button
                Button(action: saveSettings) {
                    Text("SAVE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
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
                }
                .buttonStyle(.plain)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .appBackgroundGradient()
    }
    
    private func saveSettings() {
        viewModel.updateSettings(
            focusMinutes: Int(tempFocusMinutes),
            breakMinutes: Int(tempBreakMinutes)
        )
        dismiss()
    }
}

#Preview {
    SettingsView(viewModel: TimerViewModel(feedbackProvider: HapticManager.shared))
}
