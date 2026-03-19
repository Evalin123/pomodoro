//
//  ContentView.swift
//  Pomodoro (iOS) - Nature Organic
//
//  Created on 2026/3/13.
//  Updated on 2026/3/18 - Phone Layout with Navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: NotificationManager.shared)
    @State private var pulseAnimation = false
    @State private var showSettings = false
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    // Logo and title
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        // Logo with gradient
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
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
                                .frame(width: 32, height: 32)
                                .organicShadow()
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Pomodoro Timer")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        // History button
                        Button(action: { showHistory = true }) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.6))
                                )
                        }
                        
                        // Settings button
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.6))
                                )
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.md)
                
                // Main timer area
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Spacer()
                    
                    // Session type badge
                    sessionBadge
                        .padding(.bottom, DesignSystem.Spacing.md)
                    
                    // Circular progress indicator
                    CircularProgressView(
                        progress: viewModel.progress,
                        minutes: currentMinutes,
                        seconds: currentSeconds,
                        isWorkMode: viewModel.isWorkMode,
                        isRunning: viewModel.isRunning,
                        subtitle: viewModel.isWorkMode ? "Deep Work" : "Relax & Breathe"
                    )
                    .id(viewModel.uiUpdateTrigger)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                    
                    // Control buttons
                    controlButtons
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Stats summary
                    statsSummary
                        .padding(.top, DesignSystem.Spacing.lg)
                    
                    Spacer()
                }
            }
        }
        .appBackgroundGradient()
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView(viewModel: viewModel)
        }
        .onAppear {
            NotificationManager.shared.clearBadge()
            withAnimation(DesignSystem.animationNormal.repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
        .onDisappear {
            pulseAnimation = false
        }
    }
    
    // MARK: - Session Badge
    private var sessionBadge: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if viewModel.isWorkMode {
                Circle()
                    .fill(DesignSystem.Colors.workMode)
                    .frame(width: 10, height: 10)
                    .scaleEffect(pulseAnimation && viewModel.isRunning ? 1.3 : 1.0)
                    .shadow(color: DesignSystem.Colors.workMode.opacity(0.6), radius: 8)
                
                Text("Focus Flow")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.workMode)
            } else {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.restMode)
                
                Text("Break Time")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.restMode)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                .fill(.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                        .stroke(DesignSystem.Colors.borderSubtle.opacity(0.6), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            // Reset button (smaller, circular)
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.resetTimer()
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.8))
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.borderSubtle.opacity(0.8), lineWidth: 1)
                            )
                            .organicShadow()
                    )
            }
            .buttonStyle(.plain)
            
            // Main play/pause button (larger, circular)
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.startTimer()
                }
            }) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: viewModel.isWorkMode ?
                                        [DesignSystem.Colors.workMode, DesignSystem.Colors.workMode.opacity(0.8)] :
                                        [DesignSystem.Colors.restMode, DesignSystem.Colors.restMode.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .progressGlow(
                                color: viewModel.isWorkMode ? DesignSystem.Colors.workMode : DesignSystem.Colors.restMode,
                                isActive: true
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Stats Summary
    private var statsSummary: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.restMode)
            
            Text("\(viewModel.sessionsCompleted) sessions grown today")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .fill(.white.opacity(0.4))
        )
    }
    
    // MARK: - Computed Properties
    private var currentMinutes: Int {
        let remaining = viewModel.displayRemainingTime
        return Int(remaining) / 60
    }
    
    private var currentSeconds: Int {
        let remaining = viewModel.displayRemainingTime
        return Int(remaining) % 60
    }
}

#Preview {
    ContentView()
}
