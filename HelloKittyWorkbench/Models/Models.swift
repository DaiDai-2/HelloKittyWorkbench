import Foundation
import CoreData

// MARK: - 通用可编码模型协议
protocol HKModel: Codable, Identifiable {
    var id: UUID { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var isSynced: Bool { get set }
    var tableName: String { get }
}

// MARK: - 饮食记录模型
struct DietRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var foodName: String
    var calories: Double
    var portion: String
    var date: Date
    var mealType: String // breakfast/lunch/dinner/snack
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "diet_records" }
}

// MARK: - 饮水记录模型
struct WaterRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var amount: Double // ml
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "water_records" }
}

// MARK: - 收支记录模型
struct TransactionRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var type: TransactionType // income/expense
    var amount: Double
    var category: String
    var note: String
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "transactions" }
    
    enum TransactionType: String, Codable, CaseIterable {
        case income = "收入"
        case expense = "支出"
    }
}

// MARK: - 分类模型
struct CategoryItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: String // income/expense
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "categories" }
}

// MARK: - 支出规划模型
struct BudgetPlan: Codable, Identifiable {
    var id: UUID = UUID()
    var monthlySalary: Double
    var needsPercent: Double = 50
    var wantsPercent: Double = 30
    var savingsPercent: Double = 20
    var month: Date // 月份
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "budget_plans" }
    
    var needsAmount: Double { monthlySalary * needsPercent / 100 }
    var wantsAmount: Double { monthlySalary * wantsPercent / 100 }
    var savingsAmount: Double { monthlySalary * savingsPercent / 100 }
}

// MARK: - 欠款记录模型
struct DebtRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var type: DebtType // oweTo/owedBy
    var personName: String
    var amount: Double
    var note: String
    var date: Date
    var isPaid: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "debts" }
    
    enum DebtType: String, Codable, CaseIterable {
        case oweTo = "我欠别人"
        case owedBy = "别人欠我"
    }
}

// MARK: - 存钱目标模型
struct SavingsGoal: Codable, Identifiable {
    var id: UUID = UUID()
    var targetName: String
    var targetAmount: Double
    var currentAmount: Double = 0
    var targetDate: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    var isCompleted: Bool = false
    
    var tableName: String { "savings_goals" }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}

// MARK: - 运动记录模型
struct ExerciseRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var type: ExerciseType
    var exerciseName: String
    var duration: Double // 分钟
    var caloriesBurned: Double
    var note: String
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "exercise_records" }
    
    enum ExerciseType: String, Codable, CaseIterable {
        case cardio = "有氧"
        case strength = "无氧"
        case other = "其他"
    }
}

// MARK: - 体重记录模型
struct WeightRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var weight: Double // kg
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "weight_records" }
}

// MARK: - 用户信息模型
struct UserProfile: Codable {
    var gender: Gender = .female
    var height: Double = 165 // cm
    var birthYear: Int = 2000
    var nickname: String = "小可爱"
    var avatarData: Data? = nil
    var waterGoal: Double = 2000
    
    enum Gender: String, Codable, CaseIterable {
        case male = "男"
        case female = "女"
    }
    
    var bmi: Double? {
        guard let latestWeight = UserDefaults.standard.object(forKey: "latestWeight") as? Double, height > 0 else { return nil }
        return latestWeight / ((height / 100) * (height / 100))
    }
}

// MARK: - 书籍模型
struct Book: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var author: String
    var category: String
    var recommendation: String
    var difficulty: DifficultyLevel
    var readStatus: ReadStatus = .wantToRead
    var currentPage: Int = 0
    var totalPage: Int = 0
    var coverColor: String // 占位色块颜色
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "books" }
    
    var progress: Double {
        guard totalPage > 0 else { return 0 }
        return min(Double(currentPage) / Double(totalPage), 1.0)
    }
    
    enum DifficultyLevel: String, Codable, CaseIterable {
        case beginner = "入门"
        case intermediate = "进阶"
        case advanced = "深度"
    }
    
    enum ReadStatus: String, Codable, CaseIterable {
        case wantToRead = "想读"
        case reading = "在读"
        case finished = "已读"
    }
}

// MARK: - 阅读笔记模型
struct ReadingNote: Codable, Identifiable {
    var id: UUID = UUID()
    var bookId: UUID
    var content: String
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "reading_notes" }
}

// MARK: - 阅读内容模型
struct ReadingContent: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var fontSize: Double = 16
    var bgColor: String = "white" // white/cream/green
    var currentPage: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "reading_contents" }
}

// MARK: - 学习目标模型
struct StudyGoal: Codable, Identifiable {
    var id: UUID = UUID()
    var targetSchool: String = ""
    var targetMajor: String = ""
    var examDate: Date = Date().addingTimeInterval(365 * 24 * 3600)
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "study_goals" }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date().startOfDay, to: examDate.startOfDay)
        return max(components.day ?? 0, 0)
    }
}

// MARK: - 考试科目模型
struct ExamSubject: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var targetScore: Double = 100
    var currentScore: Double = 0
    var progress: Double = 0 // 0~1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "exam_subjects" }
}

// MARK: - 计划打卡模型
struct HabitPlan: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var frequency: HabitFrequency
    var startDate: Date = Date()
    var endDate: Date? = nil
    var isPaused: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "habit_plans" }
    
    enum HabitFrequency: Codable {
        case daily
        case weekly(Int)  // 每周X次
        case custom(Int)  // 自定义天数
        
        var label: String {
            switch self {
            case .daily: return "每天"
            case .weekly(let count): return "每周\(count)次"
            case .custom(let days): return "每\(days)天"
            }
        }
    }
}

// MARK: - 打卡记录模型
struct HabitCheckIn: Codable, Identifiable {
    var id: UUID = UUID()
    var habitId: UUID
    var date: Date
    var isDone: Bool = true
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "habit_checkins" }
}

// MARK: - 心情记录模型
struct MoodRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var moodLevel: MoodLevel
    var diary: String
    var tags: [String]
    var date: Date
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSynced: Bool = false
    
    var tableName: String { "mood_records" }
    
    enum MoodLevel: String, Codable, CaseIterable {
        case happy = "😄"
        case good = "😊"
        case neutral = "😐"
        case sad = "😢"
        case bad = "😫"
        
        var label: String {
            switch self {
            case .happy: return "开心"
            case .good: return "不错"
            case .neutral: return "一般"
            case .sad: return "低落"
            case .bad: return "很差"
            }
        }
        
        var color: String {
            switch self {
            case .happy: return "#FFB6C1"
            case .good: return "#FFD1DC"
            case .neutral: return "#E8D5B7"
            case .sad: return "#B0C4DE"
            case .bad: return "#A9A9A9"
            }
        }
    }
}

// MARK: - Codable扩展（为可选的HabitFrequency）
extension HabitPlan.HabitFrequency: Codable {
    enum CodingKeys: String, CodingKey { case type, count }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let count = try container.decode(Int.self, forKey: .count)
        switch type {
        case "daily": self = .daily
        case "weekly": self = .weekly(count)
        case "custom": self = .custom(count)
        default: self = .daily
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .daily:
            try container.encode("daily", forKey: .type)
            try container.encode(1, forKey: .count)
        case .weekly(let count):
            try container.encode("weekly", forKey: .type)
            try container.encode(count, forKey: .count)
        case .custom(let count):
            try container.encode("custom", forKey: .type)
            try container.encode(count, forKey: .count)
        }
    }
}
