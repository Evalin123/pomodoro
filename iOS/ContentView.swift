//
//  ContentView.swift
//  Pomodoro (iOS)
//
//  Created on 2026/3/12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel(feedbackProvider: NotificationManager.shared)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // 狀態標籤
                Text(viewModel.statusText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(viewModel.isWorkMode ? .red : .green)
                
                // 計時器顯示
                if let targetDate = viewModel.targetDate, viewModel.isRunning {
                    Text(targetDate, style: .timer)
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                } else {
                    Text(formatTime(viewModel.currentDuration))
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 控制按鈕
                VStack(spacing: 20) {
                    // 開始/暫停按鈕
                    Button(action: {
                        viewModel.startTimer()
                    }) {
                        Text(viewModel.buttonText)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(viewModel.isRunning ? Color.orange : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    HStack(spacing: 16) {
                        // 重置按鈕
                        Button(action: {
                            viewModel.resetTimer()
                        }) {
                            Label("重置", systemImage: "arrow.counterclockwise")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 切換模式按鈕
                        Button(action: {
                            viewModel.switchMode()
                        }) {
                            Label(viewModel.isWorkMode ? "切換休息" : "切換工作", 
                                  systemImage: viewModel.isWorkMode ? "cup.and.saucer.fill" : "briefcase.fill")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(viewModel.isWorkMode ? Color.green : Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(viewModel.isRunning)
                        .opacity(viewModel.isRunning ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("番茄鐘")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 清除通知角標
                NotificationManager.shared.clearBadge()
            }
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
