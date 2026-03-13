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
                .frame(minWidth: 400, idealWidth: 450, minHeight: 350, idealHeight: 400)
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
