//
//  ContentView.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: NotificationManager.shared)
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 狀態標籤
            Text(viewModel.statusText)
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(viewModel.isWorkMode ? .red : .green)
            
            // 計時器顯示
            if let targetDate = viewModel.targetDate, viewModel.isRunning {
                Text(targetDate, style: .timer)
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(formatTime(viewModel.currentDuration))
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 控制按鈕
            VStack(spacing: 16) {
                // 開始/暫停按鈕
                Button(action: {
                    viewModel.startTimer()
                }) {
                    Text(viewModel.buttonText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRunning ? .orange : .blue)
                .controlSize(.large)
                
                HStack(spacing: 12) {
                    // 重置按鈕
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Label("重置", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    // 切換模式按鈕
                    Button(action: {
                        viewModel.switchMode()
                    }) {
                        Label(viewModel.isWorkMode ? "休息" : "工作", 
                              systemImage: viewModel.isWorkMode ? "cup.and.saucer.fill" : "briefcase.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(viewModel.isRunning)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(40)
        .frame(minWidth: 400, idealWidth: 450, minHeight: 350, idealHeight: 400)
        .onAppear {
            // 清除通知角標
            NotificationManager.shared.clearBadge()
        }
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
