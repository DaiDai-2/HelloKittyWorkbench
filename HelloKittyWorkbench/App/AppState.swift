import SwiftUI
import Combine

/// 全局应用状态管理
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var syncStatus: SyncStatus = .disconnected
    @Published var supabaseConfigured: Bool {
        didSet {
            UserDefaults.standard.set(supabaseConfigured, forKey: "supabaseConfigured")
        }
    }
    
    @Published var studyModuleDeleted: Bool {
        didSet {
            UserDefaults.standard.set(studyModuleDeleted, forKey: "studyModuleDeleted")
        }
    }
    
    @Published var userProfile: UserProfile = UserProfile()
    @Published var dailyQuote: String = ""
    
    // 今日汇总数据
    @Published var todayCalories: Double = 0
    @Published var todayWater: Double = 0
    @Published var waterGoal: Double = 2000
    @Published var todayIncome: Double = 0
    @Published var todayExpense: Double = 0
    @Published var todayExercised: Bool = false
    @Published var currentWeight: Double = 0
    @Published var currentBMI: Double = 0
    @Published var todayMood: String = ""
    @Published var todayHabitsDone: Int = 0
    @Published var todayHabitsTotal: Int = 0
    
    private let quotes: [String] = [
        "每一天都是一个新的开始 🌸",
        "你值得所有的美好 ✨",
        "慢慢来，比较快 💕",
        "做自己的小太阳 🌞",
        "热爱可抵岁月漫长 💖",
        "今天的努力是明天的礼物 🎀",
        "小小的坚持，大大的改变 🌷",
        "保持可爱，保持努力 🐱",
        "生活明朗，万物可爱 🌈",
        "自信的你最美丽 👑",
        "每一个好习惯都在塑造更好的你 💎",
        "不要停止奔跑，不要回顾来路 🏃‍♀️",
        "你是独一无二的星星 ⭐",
        "温柔且有力量 🌸",
        "把每一天过成喜欢的样子 🎨",
        "好运藏在努力里 🍀",
        "心中有光，脚下有路 ✨",
        "美好的事情即将发生 💫",
        "做最好的自己，遇见最好的未来 🌟",
        "热爱生活，生活也会爱你 💗",
        "保持好奇心，世界很精彩 🌍",
        "每一个不曾起舞的日子，都是对生命的辜负 💃",
        "你比想象中更强大 💪",
        "今天也是元气满满的一天 🎉",
        "梦想不会发光，发光的是追梦的你 🌙",
        "生活就像一盒巧克力 🍫",
        "愿你成为自己的太阳 ☀️",
        "花开不是为了花落，而是为了绽放 🌺",
        "心有猛虎，细嗅蔷薇 🐯",
        "保持热爱，奔赴山海 ⛰️",
        "所有的美好都会如期而至 🌸",
        "努力的人运气不会太差 🍀",
        "心之所向，素履以往 🚶‍♀️",
        "不负韶华，未来可期 📅",
        "你的坚持终将美好 💎",
        "向阳而生，逐光而行 🌻",
        "做颗星星，有棱有角，还会发光 ⭐",
        "以梦为马，不负韶华 🐴",
        "眼里有光，心中有爱 💖",
        "笑口常开，好运自然来 😊",
        "温柔半两，从容一生 🍵",
        "彼方尚有荣光在 🌅",
        "星光不问赶路人 ✨",
        "行而不辍，未来可期 🛤️",
        "山不让尘，川不辞盈 🏔️",
        "追光的人，终会光芒万丈 💫",
        "前路浩浩荡荡，万事尽可期待 🌈",
        "你一定要站在自己所热爱的世界里闪闪发光 💖",
        "把身体照顾好，把喜欢的事做好 🌷",
        "每一天都是限量版，请尽情可爱 🎀"
    ]
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.supabaseConfigured = UserDefaults.standard.bool(forKey: "supabaseConfigured")
        self.studyModuleDeleted = UserDefaults.standard.bool(forKey: "studyModuleDeleted")
        self.dailyQuote = quotes.randomElement() ?? quotes[0]
    }
    
    func refreshDailyQuote() {
        dailyQuote = quotes.randomElement() ?? quotes[0]
    }
}

/// 同步状态枚举
enum SyncStatus {
    case connected      // 🟢 已连接
    case disconnected   // 🔴 离线
    case syncing        // 🟡 同步中
    
    var icon: String {
        switch self {
        case .connected: return "cloud.fill"
        case .disconnected: return "cloud.slash.fill"
        case .syncing: return "arrow.triangle.2.circlepath.icloud.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .connected: return .green
        case .disconnected: return .red
        case .syncing: return .orange
        }
    }
    
    var label: String {
        switch self {
        case .connected: return "已连接"
        case .disconnected: return "离线"
        case .syncing: return "同步中..."
        }
    }
}
