#!/bin/bash

echo "🍅 生成 Pomodoro Xcode 專案..."
echo ""

# 檢查 XcodeGen 是否安裝
if ! command -v xcodegen &> /dev/null; then
    echo "❌ XcodeGen 未安裝"
    echo "請執行: brew install xcodegen"
    exit 1
fi

# 生成 Xcode 專案
echo "📦 正在生成專案..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ 專案生成成功！"
    echo ""
    echo "🚀 選擇要測試的平台："
    echo "  1) iOS"
    echo "  2) macOS"
    echo "  3) watchOS"
    echo "  4) 只打開專案（不執行）"
    echo ""
    read -p "請選擇 (1-4): " choice
    
    case $choice in
        1)
            echo "📱 啟動 iOS 模擬器..."
            open -a Xcode Pomodoro.xcodeproj
            sleep 2
            xcodebuild -project Pomodoro.xcodeproj -scheme Pomodoro-iOS -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
            ;;
        2)
            echo "💻 啟動 macOS..."
            open -a Xcode Pomodoro.xcodeproj
            sleep 2
            xcodebuild -project Pomodoro.xcodeproj -scheme Pomodoro-macOS build
            ;;
        3)
            echo "⌚️ 啟動 watchOS 模擬器..."
            open -a Xcode Pomodoro.xcodeproj
            sleep 2
            xcodebuild -project Pomodoro.xcodeproj -scheme Pomodoro-watchOS -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (45mm)' build
            ;;
        4)
            echo "📂 打開 Xcode..."
            open Pomodoro.xcodeproj
            ;;
        *)
            echo "❌ 無效的選擇"
            exit 1
            ;;
    esac
else
    echo "❌ 專案生成失敗"
    exit 1
fi
