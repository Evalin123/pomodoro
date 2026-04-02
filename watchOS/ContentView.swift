//
//  ContentView.swift
//  Pomodoro (watchOS) - Circular Progress with Paging
//
//  Created on 2026/3/13.
//  Updated on 2026/3/19 - Circular Progress with Settings Page
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: HapticManager.shared)
    @State private var pulseAnimation = false
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Timer with circular progress
            TimerPageView(viewModel: viewModel, pulseAnimation: $pulseAnimation)
                .tag(0)
                .containerBackground(Color.clear, for: .tabView)
            
            // Page 2: Settings adjustment
            SettingsPageView(viewModel: viewModel)
                .tag(1)
                .containerBackground(Color.clear, for: .tabView)
        }
        .tabViewStyle(.page)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseAnimation = true
            }
        }
        .onDisappear {
            pulseAnimation = false
        }
    }
}

// MARK: - Timer Page View
struct TimerPageView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Binding var pulseAnimation: Bool
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on mode
            LinearGradient(
                colors: [
                    themeColor,
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: viewModel.sessionMode)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 30)
                
                // Circular progress with time
                CircularProgressRing(
                    progress: viewModel.progress,
                    minutes: currentMinutes,
                    seconds: currentSeconds,
                    themeColor: themeColor,
                    isRunning: viewModel.isRunning,
                    pulseAnimation: pulseAnimation,
                    sessionsCompleted: viewModel.sessionsCompleted
                )
                .id(viewModel.uiUpdateTrigger)
                
                Spacer()
                
                // Control buttons - positioned at edges (justify-between)
                HStack(spacing: 0) {
                    // Reset button (always visible)
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.resetTimer()
                        }
                        HapticManager.shared.playClick()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Play/Pause button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.startTimer()
                        }
                        HapticManager.shared.playClick()
                    }) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    private var themeColor: Color {
        switch viewModel.sessionMode {
        case .work:
            return DesignSystem.Colors.workMode
        case .shortBreak:
            return DesignSystem.Colors.restMode
        case .longBreak:
            return DesignSystem.Colors.brandAccent
        }
    }
    
    private var currentMinutes: Int {
        let remaining = viewModel.displayRemainingTime
        return Int(remaining) / 60
    }
    
    private var currentSeconds: Int {
        let remaining = viewModel.displayRemainingTime
        return Int(remaining) % 60
    }
}

// MARK: - Circular Progress Ring
struct CircularProgressRing: View {
    let progress: Double
    let minutes: Int
    let seconds: Int
    let themeColor: Color
    let isRunning: Bool
    let pulseAnimation: Bool
    let sessionsCompleted: Int
    
    private let ringSize: CGFloat = 120
    private let lineWidth: CGFloat = 16
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.white.opacity(0.2),
                    lineWidth: lineWidth
                )
                .frame(width: ringSize, height: ringSize)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    themeColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
                .shadow(
                    color: themeColor.opacity(0.6),
                    radius: 8,
                    x: 0,
                    y: 0
                )
            
            // Time display with progress dots
            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    Text(String(format: "%02d", minutes))
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(":")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(.white.opacity(0.9))
                        .opacity(pulseAnimation && isRunning ? 1.0 : 0.4)
                    
                    Text(String(format: "%02d", seconds))
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .monospacedDigit()
                
                // Tomato progress dots
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .strokeBorder(
                                index < sessionsCompleted % 4 ? themeColor : Color.white.opacity(0.3),
                                lineWidth: index < sessionsCompleted % 4 ? 0 : 1.5
                            )
                            .background(
                                Circle().fill(
                                    index < sessionsCompleted % 4 ? themeColor : Color.clear
                                )
                            )
                            .frame(width: 6, height: 6)
                            .animation(.spring(response: 0.3), value: sessionsCompleted)
                    }
                }
            }
        }
    }
}

// MARK: - Settings Page View
struct SettingsPageView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var crownValue: Double = 0
    @State private var tempMinutes: Int = 25
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    themeColor,
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: viewModel.sessionMode)
            
            VStack(spacing: 16) {
                // Title (根據模式顯示)
                Text(modeTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                // Large time display (帶晃動動畫)
                Text("\(tempMinutes)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .offset(x: shakeOffset)
                
                Text("minutes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                
                // Slider indicator
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.3))
                        .frame(height: 4)
                        .overlay(
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(themeColor)
                                    .frame(width: geometry.size.width * CGFloat(tempMinutes) / 60.0)
                            }
                        )
                    
                    HStack {
                        Text("1")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                        Text("60")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 8)
                
                // Hint text
                Text(viewModel.isRunning ? "Turn to add more time" : "Turn Digital Crown to adjust")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 4)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .focusable(true)
            .digitalCrownRotation(
                $crownValue,
                from: Double(viewModel.minAllowedMinutes),
                through: 60,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { oldValue, newValue in
                let newMinutes = Int(newValue)
                
                // 嘗試更新設定（即時保存）
                let allowed = updateCurrentModeSetting(to: newMinutes)
                
                if !allowed {
                    // 不允許減少，觸發 failure haptic 和晃動動畫
                    WKInterfaceDevice.current().play(.failure)
                    triggerShakeAnimation()
                    // 恢復原值
                    crownValue = Double(tempMinutes)
                } else {
                    // 允許，更新 tempMinutes
                    tempMinutes = newMinutes
                }
            }
            .onAppear {
                tempMinutes = viewModel.currentMinutes
                crownValue = Double(tempMinutes)
            }
        }
    }
    
    private var modeTitle: String {
        switch viewModel.sessionMode {
        case .work:
            return "Focus Time"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    private var themeColor: Color {
        switch viewModel.sessionMode {
        case .work:
            return DesignSystem.Colors.workMode
        case .shortBreak:
            return DesignSystem.Colors.restMode
        case .longBreak:
            return DesignSystem.Colors.brandAccent
        }
    }
    
    // 更新當前模式的設定
    private func updateCurrentModeSetting(to minutes: Int) -> Bool {
        switch viewModel.sessionMode {
        case .work:
            return viewModel.updateSettings(focusMinutes: minutes)
        case .shortBreak:
            return viewModel.updateSettings(breakMinutes: minutes)
        case .longBreak:
            return viewModel.updateSettings(longBreakMinutes: minutes)
        }
    }
    
    // 觸發晃動動畫
    private func triggerShakeAnimation() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            shakeOffset = 10
        }
        
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                shakeOffset = -10
            }
            
            try? await Task.sleep(for: .milliseconds(100))
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                shakeOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
