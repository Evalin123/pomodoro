//
//  PomodoroApp.swift
//  Pomodoro (macOS)
//
//  Created on 2026/3/12.
//

import SwiftUI

@main
struct PomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands {
            // 可以在這裡加入自訂選單指令
            CommandGroup(replacing: .newItem) {
                // 移除 "New" 選單項目
            }
        }
    }
}
