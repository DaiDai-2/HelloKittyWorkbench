import Foundation

/// 心情日记 ViewModel
class MoodViewModel: ObservableObject {
    @Published var moodRecords: [MoodRecord] = []
    @Published var selectedFilter: MoodRecord.MoodLevel? = nil
    @Published var customTags: [String] = []
    
    private let storage = LocalStorageManager.shared
    
    let defaultTags = ["工作", "社交", "运动", "学习", "美食", "旅行", "家人", "朋友", "独处", "阅读"]
    
    var allTags: [String] {
        defaultTags + customTags
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        moodRecords = storage.loadMoodRecords()
    }
    
    func addMood(level: MoodRecord.MoodLevel, diary: String = "", tags: [String] = [], date: Date = Date()) {
        let record = MoodRecord(moodLevel: level, diary: diary, tags: tags, date: date)
        moodRecords.append(record)
        saveRecords()
        hkHaptic(.medium)
    }
    
    func deleteMood(_ record: MoodRecord) {
        moodRecords.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    func addCustomTag(_ tag: String) {
        guard !tag.isEmpty, !allTags.contains(tag) else { return }
        customTags.append(tag)
    }
    
    // MARK: - 筛选
    var filteredRecords: [MoodRecord] {
        if let filter = selectedFilter {
            return moodRecords.filter { $0.moodLevel == filter }.sorted { $0.date > $1.date }
        }
        return moodRecords.sorted { $0.date > $1.date }
    }
    
    /// 今日心情
    var todayMood: MoodRecord? {
        moodRecords.first { $0.date.startOfDay == Date().startOfDay }
    }
    
    /// 心情日历数据
    var moodCalendarData: [Date: MoodRecord.MoodLevel] {
        var dict: [Date: MoodRecord.MoodLevel] = [:]
        for record in moodRecords {
            let day = record.date.startOfDay
            if dict[day] == nil {
                dict[day] = record.moodLevel
            }
        }
        return dict
    }
    
    /// 心情统计（最近N天）
    func moodStats(days: Int) -> [(level: MoodRecord.MoodLevel, count: Int, percentage: Double)] {
        let startDate = Calendar.current.date(byAdding: .day, value: -(days - 1), to: Date().startOfDay) ?? Date()
        let recentRecords = moodRecords.filter { $0.date.startOfDay >= startDate }
        let total = recentRecords.count
        
        return MoodRecord.MoodLevel.allCases.map { level in
            let count = recentRecords.filter { $0.moodLevel == level }.count
            let percentage = total > 0 ? Double(count) / Double(total) * 100 : 0
            return (level, count, percentage)
        }
    }
    
    /// 搜索日记
    func searchDiary(keyword: String) -> [MoodRecord] {
        guard !keyword.isEmpty else { return [] }
        return moodRecords.filter {
            $0.diary.localizedCaseInsensitiveContains(keyword)
        }.sorted { $0.date > $1.date }
    }
    
    private func saveRecords() {
        storage.saveMoodRecords(moodRecords)
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.todayMood = self.todayMood?.moodLevel.label ?? ""
        }
    }
}
