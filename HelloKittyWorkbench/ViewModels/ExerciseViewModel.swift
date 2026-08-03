import Foundation
import Combine

/// 健康运动 ViewModel
class ExerciseViewModel: ObservableObject {
    @Published var exerciseRecords: [ExerciseRecord] = []
    
    private let storage = LocalStorageManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        exerciseRecords = storage.loadExerciseRecords()
    }
    
    func addExercise(type: ExerciseRecord.ExerciseType, name: String, duration: Double, calories: Double? = nil, note: String = "", date: Date = Date()) {
        let estimatedCalories = calories ?? estimateCalories(type: type, duration: duration)
        let record = ExerciseRecord(
            type: type,
            exerciseName: name,
            duration: duration,
            caloriesBurned: estimatedCalories,
            note: note,
            date: date
        )
        exerciseRecords.append(record)
        saveRecords()
        hkHaptic(.medium)
    }
    
    func deleteExercise(_ record: ExerciseRecord) {
        exerciseRecords.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    /// 估算消耗卡路里（大致的）
    private func estimateCalories(type: ExerciseRecord.ExerciseType, duration: Double) -> Double {
        switch type {
        case .cardio: return duration * 8  // 跑步约8kcal/分钟
        case .strength: return duration * 6
        case .other: return duration * 4
        }
    }
    
    // MARK: - 统计
    
    /// 本周记录
    var thisWeekRecords: [ExerciseRecord] {
        let start = Date().startOfWeek
        return exerciseRecords.filter { $0.date >= start }
    }
    
    /// 本月记录
    var thisMonthRecords: [ExerciseRecord] {
        let start = Date().startOfMonth
        return exerciseRecords.filter { $0.date >= start }
    }
    
    /// 本周运动次数
    var weekCount: Int { thisWeekRecords.count }
    
    /// 本周总时长
    var weekDuration: Double { thisWeekRecords.reduce(0) { $0 + $1.duration } }
    
    /// 本周总消耗
    var weekCalories: Double { thisWeekRecords.reduce(0) { $0 + $1.caloriesBurned } }
    
    /// 本月运动次数
    var monthCount: Int { thisMonthRecords.count }
    
    /// 本月总时长
    var monthDuration: Double { thisMonthRecords.reduce(0) { $0 + $1.duration } }
    
    /// 本月总消耗
    var monthCalories: Double { thisMonthRecords.reduce(0) { $0 + $1.caloriesBurned } }
    
    /// 有氧vs无氧比例
    var cardioRatio: Double {
        let cardio = thisWeekRecords.filter { $0.type == .cardio }.count
        let total = thisWeekRecords.count
        return total > 0 ? Double(cardio) / Double(total) : 0
    }
    
    /// 连续打卡天数
    var streakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date().startOfDay
        
        while true {
            let records = exerciseRecords.filter { $0.date.startOfDay == currentDate }
            if records.isEmpty { break }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        return streak
    }
    
    /// 今日是否有运动
    var todayExercised: Bool {
        let today = Date().startOfDay
        return exerciseRecords.contains { $0.date.startOfDay == today }
    }
    
    /// 打卡日期集合（用于日历标记）
    var checkInDates: Set<Date> {
        Set(exerciseRecords.map { $0.date.startOfDay })
    }
    
    /// 指定日期的记录
    func recordsFor(date: Date) -> [ExerciseRecord] {
        exerciseRecords.filter { $0.date.startOfDay == date.startOfDay }
    }
    
    // MARK: - 预设运动类型
    let cardioExercises = ["跑步", "游泳", "骑车", "跳绳", "快走", "椭圆机", "登山"]
    let strengthExercises = ["力量训练", "哑铃", "俯卧撑", "深蹲", "引体向上", "卧推", "硬拉", "卷腹"]
    let otherExercises = ["瑜伽", "拉伸", "普拉提", "太极", "舞蹈"]
    
    private func saveRecords() {
        storage.saveExerciseRecords(exerciseRecords)
        DataSyncService.shared.markNeedsSync(table: "exercise_records")
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.todayExercised = self.todayExercised
        }
    }
}
