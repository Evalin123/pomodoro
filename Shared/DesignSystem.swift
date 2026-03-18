//
//  DesignSystem.swift
//  Pomodoro - Nature Organic (S12)
//
//  Created on 2026/3/13.
//

import SwiftUI

/// Nature Organic Design System (S12)
/// 基於大地色系、有機形狀、自然流動的設計語言
enum DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        // Background
        static let bgPrimary = Color(hex: "F8F7F4")
        static let bgSecondary = Color(hex: "F0EDE6")
        
        // Text
        static let textPrimary = Color(hex: "2D3748")
        static let textSecondary = Color(hex: "4A5568")
        static let textMuted = Color(hex: "718096")
        
        // Brand
        static let brandPrimary = Color(hex: "38A169")      // 自然綠
        static let brandSecondary = Color(hex: "805AD5")    // 紫色
        static let brandAccent = Color(hex: "3182CE")       // 藍色
        
        // State
        static let success = Color(hex: "38A169")
        static let warning = Color(hex: "D69E2E")
        static let error = Color(hex: "E53E3E")
        
        // Border
        static let borderStrong = Color(hex: "CBD5E0")
        static let borderSubtle = Color(hex: "E2E8F0")
        
        // Work/Rest specific
        static let workMode = Color(hex: "D69E2E")          // 橙色代表工作（專注/警示）
        static let restMode = Color(hex: "38A169")          // 綠色代表休息（自然/放鬆）
    }
    
    // MARK: - Typography
    enum FontSize {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 14
        static let base: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 64  // 計時器大字
    }
    
    // MARK: - Radius
    enum Radius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let organic: CGFloat = 20  // 有機曲線
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Animation
    static let animationFast = Animation.easeOut(duration: 0.2)
    static let animationNormal = Animation.easeOut(duration: 0.4)
    static let animationSlow = Animation.easeOut(duration: 1.0)
}

// MARK: - Additional Modifiers
extension View {
    /// Glass morphism effect - semi-transparent blur background
    func glassMorphism() -> some View {
        self
            .background(.ultraThinMaterial)
    }
    
    /// Circular progress shadow with glow effect
    func progressGlow(color: Color, isActive: Bool = true) -> some View {
        self.shadow(
            color: isActive ? color.opacity(0.4) : Color.clear,
            radius: 20,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Color Extension (Hex Support)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - View Modifiers
extension View {
    func organicShadow(level: Int = 1) -> some View {
        let opacity = level == 1 ? 0.06 : 0.08
        let radius: CGFloat = level == 1 ? 8 : 16
        let y: CGFloat = level == 1 ? 2 : 4
        return self.shadow(color: Color.black.opacity(opacity), radius: radius, x: 0, y: y)
    }
    
    func organicCard(color: Color = DesignSystem.Colors.bgSecondary) -> some View {
        self
            .background(RoundedRectangle(cornerRadius: DesignSystem.Radius.organic).fill(color))
            .organicShadow()
    }
}
