//
//  HistoryView.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/19.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                Text("History")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                
                if viewModel.sessions.isEmpty {
                    // Empty state
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Spacer()
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                        
                        Text("No sessions")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        
                        Spacer()
                    }
                    .frame(minHeight: 120)
                } else {
                    // Sessions list
                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(viewModel.sessions.reversed()) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .appBackgroundGradient()
    }
}

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 24, height: 24)
                
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            Text(sessionTitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            Text(formatDuration(session.duration))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(iconColor)
                .monospacedDigit()
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .fill(.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    private var iconName: String {
        session.type == .focus ? "leaf.fill" : "cup.and.saucer.fill"
    }
    
    private var iconColor: Color {
        session.type == .focus ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode
    }
    
    private var sessionTitle: String {
        session.type == .focus ? "Focus" : "Break"
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes)m"
    }
}

#Preview {
    HistoryView(viewModel: TimerViewModel(feedbackProvider: HapticManager.shared))
}
