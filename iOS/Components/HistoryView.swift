//
//  HistoryView.swift
//  Pomodoro (iOS)
//
//  Created on 2026/3/18.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    Text("History")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.sm)
                
                if viewModel.sessions.isEmpty {
                    // Empty state
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Spacer()
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 64, weight: .light))
                            .foregroundStyle(DesignSystem.Colors.textMuted.opacity(0.5))
                        
                        Text("No sessions yet")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        
                        Text("Complete your first Pomodoro session to see your history here")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(DesignSystem.Colors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.xxl)
                        
                        Spacer()
                    }
                } else {
                    // Sessions list
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(viewModel.sessions.reversed()) { session in
                                SessionRowView(session: session)
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                    }
                }
            }
        }
        .appBackgroundGradient()
        .navigationBarHidden(true)
    }
}

struct SessionRowView: View {
    let session: Session
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sessionTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(formatTime(session.timestamp))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DesignSystem.Colors.textMuted)
            }
            
            Spacer()
            
            Text(formatDuration(session.duration))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .monospacedDigit()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .fill(.white)
                .organicShadow()
        )
    }
    
    private var iconName: String {
        session.type == .focus ? "brain.filled.head.profile" : "cup.and.saucer.fill"
    }
    
    private var iconColor: Color {
        session.type == .focus ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode
    }
    
    private var sessionTitle: String {
        session.type == .focus ? "Focus Session" : "Break Time"
    }
    
    private func formatTime(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes) min"
    }
}

#Preview {
    HistoryView(viewModel: TimerViewModel(feedbackProvider: NotificationManager.shared))
}
