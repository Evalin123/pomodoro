//
//  ContentView.swift
//  Pomodoro (macOS) - Nature Organic
//
//  Created on 2026/3/13.
//  Updated on 2026/3/18 - Desktop Layout with Sidebar
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: NotificationManager.shared)
    @State private var showSettings = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top menu bar
            MenuBarView(showSettings: $showSettings)
            
            // Main content area - two column layout
            HStack(spacing: 0) {
                // Left: Main timer area
                mainTimerArea
                
                // Right: Sidebar (stats or settings)
                SidebarView(viewModel: viewModel, showSettings: $showSettings)
            }
        }
        .background(
            // Three-color gradient background
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "F8F7F4"), location: 0),
                    .init(color: Color(hex: "F0EDE6"), location: 0.5),
                    .init(color: Color(hex: "E8E5DC"), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .frame(minWidth: 900, idealWidth: 1000, minHeight: 600, idealHeight: 700)
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
    
    // MARK: - Main Timer Area
    private var mainTimerArea: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Session indicator badge
            sessionBadge
            
            // Large circular timer
            CircularProgressView(
                progress: viewModel.progress,
                minutes: currentMinutes,
                seconds: currentSeconds,
                isWorkMode: viewModel.isWorkMode,
                isRunning: viewModel.isRunning,
                subtitle: viewModel.isWorkMode ? "Stay focused on your task" : "Relax and recharge"
            )
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .id(viewModel.uiUpdateTrigger)  // 使用 trigger 強制更新
            
            // Control buttons
            controlButtons
                .padding(.horizontal, DesignSystem.Spacing.xxl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
                
                Text("Focus Session")
                    .font(.system(size: DesignSystem.FontSize.base, weight: .medium, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.workMode)
            } else {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: DesignSystem.FontSize.base, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.restMode)
                
                Text("Break Time")
                    .font(.system(size: DesignSystem.FontSize.base, weight: .medium, design: .rounded))
                    .foregroundStyle(DesignSystem.Colors.restMode)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.organic)
                        .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
                )
                .organicShadow()
        )
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Reset button (smaller, circular)
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.resetTimer()
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(.white)
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
                            )
                            .organicShadow()
                    )
            }
            .buttonStyle(.plain)
            .scaleEffect(1.0)
            .animation(DesignSystem.animationFast, value: viewModel.isRunning)
            
            // Main play/pause button (larger, circular)
            Button(action: {
                withAnimation(DesignSystem.animationFast) {
                    viewModel.startTimer()
                }
            }) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
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
            .scaleEffect(1.0)
            .animation(DesignSystem.animationFast, value: viewModel.isRunning)
        }
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
