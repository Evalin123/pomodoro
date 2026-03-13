//
//  ContentView.swift
//  Pomodoro (watchOS)
//
//  Created on 2026/3/12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: HapticManager.shared)
    
    var body: some View {
        VStack(spacing: 8) {
            // 狀態標籤
            Text(viewModel.statusText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.isWorkMode ? .red : .green)
            
            // 計時器顯示
            if let targetDate = viewModel.targetDate, viewModel.isRunning {
                Text(targetDate, style: .timer)
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(formatTime(viewModel.currentDuration))
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            
            // 控制按鈕
            VStack(spacing: 8) {
                // 開始/暫停按鈕
                Button(action: {
                    viewModel.startTimer()
                    if viewModel.isRunning {
                        HapticManager.shared.playStart()
                    } else {
                        HapticManager.shared.playStop()
                    }
                }) {
                    Text(viewModel.buttonText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRunning ? .orange : .blue)
                
                HStack(spacing: 8) {
                    // 重置按鈕
                    Button(action: {
                        viewModel.resetTimer()
                        HapticManager.shared.playClick()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    
                    // 切換模式按鈕
                    Button(action: {
                        viewModel.switchMode()
                        HapticManager.shared.playClick()
                    }) {
                        Image(systemName: viewModel.isWorkMode ? "cup.and.saucer.fill" : "briefcase.fill")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.isWorkMode ? .green : .red)
                    .disabled(viewModel.isRunning)
                    .opacity(viewModel.isRunning ? 0.5 : 1.0)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
