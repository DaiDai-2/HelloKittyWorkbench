import Foundation

/// 计划打卡 ViewModel
class HabitViewModel: ObservableObject {
    @Published var plans: [HabitPlan] = []
    @Published var checkIns: [HabitCheckIn] = []
    
    private let storage = LocalStorageManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        plans = storage.loadHabitPlans()
        checkIns = storage.loadHabitCheckIns()
    }
    
    // MARK: - 计划管理
    func addPlan(name: String, frequency: HabitPlan.HabitFrequency, startDate: Date = Date(), endDate: Date? = nil) {
        let plan = HabitPlan(name: name, frequency: frequency, startDate: startDate, endDate: endDate)
        plans.append(plan)
        savePlans()
        hkHaptic(.medium)
    }
    
    func togglePause(_ plan: HabitPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index].isPaused.toggle()
            savePlans()
        }
    }
    
    func deletePlan(_ plan: HabitPlan) {
        plans.removeAll { $0.id == plan.id }
        // 同时删除该计划的所有打卡记录
        checkIns.removeAll { $0.habitId == plan.id }
        savePlans()
        saveCheckIns()
    }
    
    /// 活跃的计划
    var activePlans: [HabitPlan] {
        plans.filter { !$0.isPaused }
    }
    
    /// 今天需要打卡的计划
    var todayPlans: [HabitPlan] {
        let today = Date().startOfDay
        return activePlans.filter { plan in
            // 开始日期不早于今天
            if plan.startDate.startOfDay > today { return false }
            // 结束日期不晚于今天
            if let endDate = plan.endDate, endDate.startOfDay < today { return false }
            
            switch plan.frequency {
            case .daily:
                return true
            case .weekly(let count):
                let weekStart = today.startOfWeek
                let checkedThisWeek = checkIns.filter {
                    $0.habitId == plan.id && $0.date.startOfDay >= weekStart
                }.count
                return checkedThisWeek < count
            case .custom:
                return true
            }
        }
    }
    
    // MARK: - 打卡
    func checkIn(for plan: HabitPlan) {
        let checkIn = HabitCheckIn(habitId: plan.id, date: Date())
        checkIns.append(checkIn)
        saveCheckIns()
        hkHaptic(.medium)
    }
    
    func undoCheckIn(for plan: HabitPlan) {
        let today = Date().startOfDay
        checkIns.removeAll { $0.habitId == plan.id && $0.date.startOfDay == today }
        saveCheckIns()
    }
    
    func isCheckedInToday(planId: UUID) -> Bool {
        let today = Date().startOfDay
        return checkIns.contains { $0.habitId == planId && $0.date.startOfDay == today }
    }
    
    // MARK: - 统计
    /// 计划完成率
    func completionRate(for plan: HabitPlan) -> Double {
        let total = checkIns.filter { $0.habitId == plan.id }.count
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: plan.startDate.startOfDay, to: Date().startOfDay).day ?? 0
        guard daysSinceStart > 0 else { return 1.0 }
        return min(Double(total) / Double(daysSinceStart + 1), 1.0)
    }
    
    /// 连续打卡天数
    func streakDays(for plan: HabitPlan) -> Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date().startOfDay
        
        while true {
            let hasCheckIn = checkIns.contains { $0.habitId == plan.id && $0.date.startOfDay == currentDate }
            if !hasCheckIn { break }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        return streak
    }
    
    /// 今日已完成数量
    var todayDoneCount: Int {
        let today = Date().startOfDay
        return checkIns.filter { $0.date.startOfDay == today }.count
    }
    
    /// 热力图数据（最近90天）
    var heatmapData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let endDate = Date().startOfDay
        let startDate = calendar.date(byAdding: .day, value: -89, to: endDate) ?? endDate
        
        var result: [(Date, Int)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let count = checkIns.filter { $0.date.startOfDay == currentDate }.count
            result.append((currentDate, count))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return result
    }
    
    private func savePlans() {
        storage.saveHabitPlans(plans)
        updateOverview()
    }
    
    private func saveCheckIns() {
        storage.saveHabitCheckIns(checkIns)
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.todayHabitsDone = self.todayDoneCount
            AppState.shared.todayHabitsTotal = self.todayPlans.count
        }
    }
}
