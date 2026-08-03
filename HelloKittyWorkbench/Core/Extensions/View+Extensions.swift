import SwiftUI
import UIKit

// MARK: - 卡片样式
extension View {
    func hkCard() -> some View {
        self
            .padding(HKStyles.cardPadding)
            .background(Color(.systemBackground))
            .cornerRadius(HKStyles.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    func hkPinkCard() -> some View {
        self
            .padding(HKStyles.cardPadding)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [HKColors.pinkLight.opacity(0.3), HKColors.pink.opacity(0.15)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(HKStyles.cardCornerRadius)
            .shadow(color: HKColors.pink.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 按钮样式
struct HKPrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [HKColors.pinkDeep, HKColors.pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(HKStyles.buttonCornerRadius)
            .shadow(color: HKColors.pink.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct HKSecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(HKColors.pinkDeep)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(HKColors.pinkLight.opacity(0.2))
            .cornerRadius(HKStyles.buttonCornerRadius)
    }
}

extension View {
    func hkPrimaryButton() -> some View {
        self.modifier(HKPrimaryButton())
    }
    
    func hkSecondaryButton() -> some View {
        self.modifier(HKSecondaryButton())
    }
}

// MARK: - 导航栏标题样式
struct HKNavigationTitle: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.textPrimary)
                }
            }
    }
}

// MARK: - Section标题
struct HKSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(HKColors.pinkDeep)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(HKColors.textPrimary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 触感反馈
func hkHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

// MARK: - 日期格式化
extension Date {
    var hkDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    var hkTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var hkFullString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: self)
    }
    
    var hkWeekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 30
    }
}

// MARK: - 数字格式化
extension Double {
    var hkCalorieString: String {
        String(format: "%.0f kcal", self)
    }
    
    var hkMoneyString: String {
        String(format: "¥%.2f", self)
    }
    
    var hkPercentString: String {
        String(format: "%.1f%%", self)
    }
}

extension Int {
    var hkWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - 字符串扩展
extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
