import SwiftUI

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum HabiBrand {
    static let cream = Color(hex: 0xFBF4EC)
    static let gradientStart = Color(hex: 0xFF9A6B)
    static let gradientEnd = Color(hex: 0xE8553A)

    static var streakGradient: LinearGradient {
        LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
