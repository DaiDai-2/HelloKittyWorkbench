import Foundation

/// 本地数据存储管理器 - 使用UserDefaults + JSON文件
/// 作为Core Data的轻量替代方案，支持离线使用
class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private let fileManager = FileManager.default
    let documentsDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - 通用存储方法
    func save<T: Codable>(_ items: [T], to filename: String) {
        let url = documentsDirectory.appendingPathComponent("\(filename).json")
        do {
            let data = try encoder.encode(items)
            try data.write(to: url)
        } catch {
            print("保存失败 \(filename): \(error)")
        }
    }
    
    func load<T: Codable>(from filename: String) -> [T] {
        let url = documentsDirectory.appendingPathComponent("\(filename).json")
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([T].self, from: data)
        } catch {
            print("加载失败 \(filename): \(error)")
            return []
        }
    }
    
    func deleteFile(_ filename: String) {
        let url = documentsDirectory.appendingPathComponent("\(filename).json")
        try? fileManager.removeItem(at: url)
    }
    
    // MARK: - 用户设置
    func saveUserProfile(_ profile: UserProfile) {
        let url = documentsDirectory.appendingPathComponent("user_profile.json")
        try? encoder.encode(profile).write(to: url)
    }
    
    func loadUserProfile() -> UserProfile {
        let url = documentsDirectory.appendingPathComponent("user_profile.json")
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let profile = try? decoder.decode(UserProfile.self, from: data) else {
            return UserProfile()
        }
        return profile
    }
    
    // MARK: - 饮食记录
    func saveDietRecords(_ records: [DietRecord]) { save(records, to: "diet_records") }
    func loadDietRecords() -> [DietRecord] { load(from: "diet_records") }
    
    // MARK: - 饮水记录
    func saveWaterRecords(_ records: [WaterRecord]) { save(records, to: "water_records") }
    func loadWaterRecords() -> [WaterRecord] { load(from: "water_records") }
    
    // MARK: - 收支记录
    func saveTransactions(_ records: [TransactionRecord]) { save(records, to: "transactions") }
    func loadTransactions() -> [TransactionRecord] { load(from: "transactions") }
    
    // MARK: - 分类
    func saveCategories(_ items: [CategoryItem]) { save(items, to: "categories") }
    func loadCategories() -> [CategoryItem] { load(from: "categories") }
    
    // MARK: - 预算
    func saveBudgetPlans(_ items: [BudgetPlan]) { save(items, to: "budget_plans") }
    func loadBudgetPlans() -> [BudgetPlan] { load(from: "budget_plans") }
    
    // MARK: - 欠款
    func saveDebts(_ items: [DebtRecord]) { save(items, to: "debts") }
    func loadDebts() -> [DebtRecord] { load(from: "debts") }
    
    // MARK: - 存钱目标
    func saveSavingsGoals(_ items: [SavingsGoal]) { save(items, to: "savings_goals") }
    func loadSavingsGoals() -> [SavingsGoal] { load(from: "savings_goals") }
    
    // MARK: - 运动记录
    func saveExerciseRecords(_ records: [ExerciseRecord]) { save(records, to: "exercise_records") }
    func loadExerciseRecords() -> [ExerciseRecord] { load(from: "exercise_records") }
    
    // MARK: - 体重记录
    func saveWeightRecords(_ records: [WeightRecord]) { save(records, to: "weight_records") }
    func loadWeightRecords() -> [WeightRecord] { load(from: "weight_records") }
    
    // MARK: - 书籍
    func saveBooks(_ items: [Book]) { save(items, to: "books") }
    func loadBooks() -> [Book] { load(from: "books") }
    
    // MARK: - 阅读笔记
    func saveReadingNotes(_ items: [ReadingNote]) { save(items, to: "reading_notes") }
    func loadReadingNotes() -> [ReadingNote] { load(from: "reading_notes") }
    
    // MARK: - 阅读内容
    func saveReadingContents(_ items: [ReadingContent]) { save(items, to: "reading_contents") }
    func loadReadingContents() -> [ReadingContent] { load(from: "reading_contents") }
    
    // MARK: - 学习目标
    func saveStudyGoal(_ goal: StudyGoal) {
        let url = documentsDirectory.appendingPathComponent("study_goal.json")
        try? encoder.encode(goal).write(to: url)
    }
    func loadStudyGoal() -> StudyGoal? {
        let url = documentsDirectory.appendingPathComponent("study_goal.json")
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(StudyGoal.self, from: data)
    }
    
    // MARK: - 考试科目
    func saveExamSubjects(_ items: [ExamSubject]) { save(items, to: "exam_subjects") }
    func loadExamSubjects() -> [ExamSubject] { load(from: "exam_subjects") }
    
    // MARK: - 计划
    func saveHabitPlans(_ items: [HabitPlan]) { save(items, to: "habit_plans") }
    func loadHabitPlans() -> [HabitPlan] { load(from: "habit_plans") }
    
    // MARK: - 打卡记录
    func saveHabitCheckIns(_ items: [HabitCheckIn]) { save(items, to: "habit_checkins") }
    func loadHabitCheckIns() -> [HabitCheckIn] { load(from: "habit_checkins") }
    
    // MARK: - 心情记录
    func saveMoodRecords(_ items: [MoodRecord]) { save(items, to: "mood_records") }
    func loadMoodRecords() -> [MoodRecord] { load(from: "mood_records") }
    
    // MARK: - 导出/导入
    func exportAllData() -> Data? {
        let exportData = ExportData(
            dietRecords: loadDietRecords(),
            waterRecords: loadWaterRecords(),
            transactions: loadTransactions(),
            categories: loadCategories(),
            budgetPlans: loadBudgetPlans(),
            debts: loadDebts(),
            savingsGoals: loadSavingsGoals(),
            exerciseRecords: loadExerciseRecords(),
            weightRecords: loadWeightRecords(),
            books: loadBooks(),
            readingNotes: loadReadingNotes(),
            readingContents: loadReadingContents(),
            studyGoal: loadStudyGoal(),
            examSubjects: loadExamSubjects(),
            habitPlans: loadHabitPlans(),
            habitCheckIns: loadHabitCheckIns(),
            moodRecords: loadMoodRecords(),
            userProfile: loadUserProfile(),
            exportDate: Date()
        )
        return try? encoder.encode(exportData)
    }
    
    func importAllData(from data: Data) -> Bool {
        guard let exportData = try? decoder.decode(ExportData.self, from: data) else { return false }
        saveDietRecords(exportData.dietRecords)
        saveWaterRecords(exportData.waterRecords)
        saveTransactions(exportData.transactions)
        saveCategories(exportData.categories)
        saveBudgetPlans(exportData.budgetPlans)
        saveDebts(exportData.debts)
        saveSavingsGoals(exportData.savingsGoals)
        saveExerciseRecords(exportData.exerciseRecords)
        saveWeightRecords(exportData.weightRecords)
        saveBooks(exportData.books)
        saveReadingNotes(exportData.readingNotes)
        saveReadingContents(exportData.readingContents)
        if let goal = exportData.studyGoal { saveStudyGoal(goal) }
        saveExamSubjects(exportData.examSubjects)
        saveHabitPlans(exportData.habitPlans)
        saveHabitCheckIns(exportData.habitCheckIns)
        saveMoodRecords(exportData.moodRecords)
        saveUserProfile(exportData.userProfile)
        return true
    }
}

/// 导出数据结构
struct ExportData: Codable {
    let dietRecords: [DietRecord]
    let waterRecords: [WaterRecord]
    let transactions: [TransactionRecord]
    let categories: [CategoryItem]
    let budgetPlans: [BudgetPlan]
    let debts: [DebtRecord]
    let savingsGoals: [SavingsGoal]
    let exerciseRecords: [ExerciseRecord]
    let weightRecords: [WeightRecord]
    let books: [Book]
    let readingNotes: [ReadingNote]
    let readingContents: [ReadingContent]
    let studyGoal: StudyGoal?
    let examSubjects: [ExamSubject]
    let habitPlans: [HabitPlan]
    let habitCheckIns: [HabitCheckIn]
    let moodRecords: [MoodRecord]
    let userProfile: UserProfile
    let exportDate: Date
}
