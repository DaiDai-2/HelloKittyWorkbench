import Foundation
import Combine

/// 饮食管理 ViewModel
class DietViewModel: ObservableObject {
    @Published var dietRecords: [DietRecord] = []
    @Published var waterRecords: [WaterRecord] = []
    @Published var waterGoal: Double = 2000
    @Published var searchQuery = ""
    @Published var searchResult: (name: String, calories: Double, portion: String)?
    @Published var showNotFound = false
    
    private let storage = LocalStorageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        waterGoal = UserDefaults.standard.double(forKey: "waterGoal")
        if waterGoal == 0 { waterGoal = 2000 }
    }
    
    func loadData() {
        dietRecords = storage.loadDietRecords()
        waterRecords = storage.loadWaterRecords()
    }
    
    // MARK: - 热量查询
    func searchFood() {
        guard !searchQuery.isEmpty else { return }
        
        if let result = HKFoodDatabase.searchFood(searchQuery) {
            searchResult = (result.name, result.typicalCalories, result.typicalPortion)
            showNotFound = false
        } else {
            searchResult = nil
            showNotFound = true
        }
    }
    
    // MARK: - 饮食记录
    func addDietRecord(foodName: String, calories: Double, portion: String, mealType: String = "snack") {
        let record = DietRecord(
            foodName: foodName,
            calories: calories,
            portion: portion,
            date: Date(),
            mealType: mealType
        )
        dietRecords.append(record)
        saveDietRecords()
        hkHaptic(.medium)
    }
    
    func deleteDietRecord(_ record: DietRecord) {
        dietRecords.removeAll { $0.id == record.id }
        saveDietRecords()
        hkHaptic(.light)
    }
    
    /// 获取今日饮食记录
    var todayDietRecords: [DietRecord] {
        let today = Date().startOfDay
        return dietRecords.filter { $0.date.startOfDay == today }
    }
    
    /// 今日总热量
    var todayTotalCalories: Double {
        todayDietRecords.reduce(0) { $0 + $1.calories }
    }
    
    /// 指定日期的饮食记录
    func dietRecordsFor(date: Date) -> [DietRecord] {
        dietRecords.filter { $0.date.startOfDay == date.startOfDay }
    }
    
    // MARK: - 饮水记录
    func addWater(amount: Double = 250) {
        let record = WaterRecord(amount: amount, date: Date())
        waterRecords.append(record)
        saveWaterRecords()
        hkHaptic(.light)
    }
    
    /// 今日饮水量
    var todayWaterTotal: Double {
        let today = Date().startOfDay
        return waterRecords
            .filter { $0.date.startOfDay == today }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// 饮水进度 (0~1)
    var waterProgress: Double {
        guard waterGoal > 0 else { return 0 }
        return min(todayWaterTotal / waterGoal, 1.0)
    }
    
    /// 指定日期的饮水量
    func waterTotalFor(date: Date) -> Double {
        waterRecords
            .filter { $0.date.startOfDay == date.startOfDay }
            .reduce(0) { $0 + $1.amount }
    }
    
    func setWaterGoal(_ goal: Double) {
        waterGoal = goal
        UserDefaults.standard.set(goal, forKey: "waterGoal")
    }
    
    // MARK: - 数据保存（自动保存）
    private func saveDietRecords() {
        storage.saveDietRecords(dietRecords)
        DataSyncService.shared.markNeedsSync(table: "diet_records")
        updateOverview()
    }
    
    private func saveWaterRecords() {
        storage.saveWaterRecords(waterRecords)
        DataSyncService.shared.markNeedsSync(table: "water_records")
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.todayCalories = self.todayTotalCalories
            AppState.shared.todayWater = self.todayWaterTotal
            AppState.shared.waterGoal = self.waterGoal
        }
    }
}
