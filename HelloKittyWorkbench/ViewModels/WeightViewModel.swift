import Foundation

/// 体重记录 ViewModel
class WeightViewModel: ObservableObject {
    @Published var weightRecords: [WeightRecord] = []
    @Published var userProfile: UserProfile
    
    private let storage = LocalStorageManager.shared
    
    init() {
        userProfile = storage.loadUserProfile()
        weightRecords = storage.loadWeightRecords()
    }
    
    func loadData() {
        weightRecords = storage.loadWeightRecords()
    }
    
    func saveProfile() {
        storage.saveUserProfile(userProfile)
    }
    
    func addWeight(_ weight: Double, date: Date = Date()) {
        let record = WeightRecord(weight: weight, date: date)
        weightRecords.append(record)
        weightRecords.sort { $0.date > $1.date }
        saveRecords()
        hkHaptic(.medium)
    }
    
    func deleteWeight(_ record: WeightRecord) {
        weightRecords.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    /// 最新体重
    var latestWeight: Double? {
        weightRecords.first?.weight
    }
    
    /// BMI
    var bmi: Double? {
        guard let weight = latestWeight, userProfile.height > 0 else { return nil }
        let heightInM = userProfile.height / 100
        return weight / (heightInM * heightInM)
    }
    
    /// BMI类别
    var bmiCategory: String {
        guard let bmi = bmi else { return "暂无数据" }
        switch bmi {
        case ..<18.5: return "偏瘦"
        case 18.5..<24: return "正常"
        case 24..<28: return "偏胖"
        default: return "肥胖"
        }
    }
    
    /// BMI颜色
    var bmiColor: String {
        guard let bmi = bmi else { return "#888888" }
        switch bmi {
        case ..<18.5: return "#87CEEB"
        case 18.5..<24: return "#7ECB76"
        case 24..<28: return "#FFD700"
        default: return "#FF6B6B"
        }
    }
    
    /// 体脂率估算 (基于BMI公式)
    var estimatedBodyFat: Double? {
        guard let bmi = bmi else { return nil }
        let age = Double(Calendar.current.component(.year, from: Date()) - userProfile.birthYear)
        let isMale = userProfile.gender == .male
        
        // Deurenberg公式估算
        let bodyFat = (1.20 * bmi) + (0.23 * age) - (isMale ? 16.2 : 5.4)
        return max(bodyFat, 0)
    }
    
    /// 标准体重 (Broca改良公式)
    var idealWeight: (min: Double, max: Double) {
        let h = userProfile.height
        let isMale = userProfile.gender == .male
        let ideal = isMale ? (h - 100) * 0.9 : (h - 100) * 0.85
        return (ideal * 0.9, ideal * 1.1)
    }
    
    /// 体重趋势数据（最近N天）
    func weightTrendData(days: Int) -> [(date: Date, weight: Double)] {
        let calendar = Calendar.current
        let endDate = Date().startOfDay
        let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: endDate) ?? endDate
        
        var result: [(Date, Double)] = []
        var currentDate = startDate
        
        // 找每个日期最近的体重记录
        while currentDate <= endDate {
            if let record = weightRecords.first(where: { $0.date.startOfDay == currentDate }) {
                result.append((currentDate, record.weight))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return result
    }
    
    private func saveRecords() {
        storage.saveWeightRecords(weightRecords)
        if let weight = latestWeight {
            UserDefaults.standard.set(weight, forKey: "latestWeight")
        }
        DataSyncService.shared.markNeedsSync(table: "weight_records")
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.currentWeight = self.latestWeight ?? 0
            AppState.shared.currentBMI = self.bmi ?? 0
        }
    }
}
