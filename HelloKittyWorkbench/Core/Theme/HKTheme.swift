import SwiftUI

// MARK: - Hello Kitty 粉色主题配色系统
struct HKColors {
    // 主色调 - 粉色系
    static let pinkLight = Color(hex: "#FFC0CB")       // 浅粉
    static let pink = Color(hex: "#FFB6C1")              // 经典粉
    static let pinkDeep = Color(hex: "#FF69B4")          // 深粉/热粉
    static let pinkRose = Color(hex: "#FF1493")          // 玫瑰粉
    
    // 背景色
    static let bgLight = Color(hex: "#FFF5F7")           // 浅粉背景
    static let bgWhite = Color(hex: "#FFFFFF")           // 纯白
    static let bgGray = Color(hex: "#F5F5F5")            // 浅灰背景
    
    // 文字色
    static let textPrimary = Color(hex: "#333333")
    static let textSecondary = Color(hex: "#888888")
    static let textPink = Color(hex: "#FF69B4")
    
    // 功能色
    static let success = Color(hex: "#7ECB76")
    static let warning = Color(hex: "#FFD700")
    static let error = Color(hex: "#FF6B6B")
    static let info = Color(hex: "#87CEEB")
    
    // 暗色模式适配
    static let cardBg = Color("cardBackground")
    static let cardShadow = Color.black.opacity(0.08)
    
    // 心情颜色
    static let moodHappy = Color(hex: "#FFB6C1")      // 开心 - 粉色
    static let moodGood = Color(hex: "#FFD1DC")        // 不错 - 浅粉
    static let moodNeutral = Color(hex: "#E8D5B7")     // 一般 - 米色
    static let moodSad = Color(hex: "#B0C4DE")          // 低落 - 灰蓝
    static let moodBad = Color(hex: "#A9A9A9")          // 很差 - 灰色
    
    // Tab选中色 - 五个Tab
    static let tab1 = Color(hex: "#FFB6C1")   // 总览
    static let tab2 = Color(hex: "#FF69B4")   // 饮食
    static let tab3 = Color(hex: "#FF1493")   // 资金
    static let tab4 = Color(hex: "#FF85A2")   // 健康
    static let tab5 = Color(hex: "#FFC0CB")   // 更多
}

// MARK: - 公共样式常量
struct HKStyles {
    static let cardCornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let buttonCornerRadius: CGFloat = 16
    static let iconSize: CGFloat = 24
    
    // 卡片修饰器
    struct CardModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(HKStyles.cardPadding)
                .background(Color(.systemBackground))
                .cornerRadius(HKStyles.cardCornerRadius)
                .shadow(color: Color.black.opacity(0.06), radius: HKStyles.cardShadowRadius, x: 0, y: 2)
        }
    }
    
    // 粉色渐变背景
    struct PinkGradientModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [HKColors.pinkLight, HKColors.bgLight]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - Color Hex扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
