import Foundation

/// 总览 ViewModel - 聚合所有模块数据
class OverviewViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    
    private let storage = LocalStorageManager.shared
    
    init() {
        userProfile = storage.loadUserProfile()
    }
    
    func loadProfile() {
        userProfile = storage.loadUserProfile()
    }
    
    func updateNickname(_ name: String) {
        userProfile.nickname = name
        saveProfile()
    }
    
    func updateAvatar(_ data: Data?) {
        userProfile.avatarData = data
        saveProfile()
    }
    
    private func saveProfile() {
        storage.saveUserProfile(userProfile)
    }
    
    // MARK: - 今日摘要数据（从AppState获取）
    var todayCalories: Double { AppState.shared.todayCalories }
    var todayWater: Double { AppState.shared.todayWater }
    var waterGoal: Double { AppState.shared.waterGoal }
    var waterProgress: Double {
        guard waterGoal > 0 else { return 0 }
        return min(todayWater / waterGoal, 1.0)
    }
    var todayIncome: Double { AppState.shared.todayIncome }
    var todayExpense: Double { AppState.shared.todayExpense }
    var todayExercised: Bool { AppState.shared.todayExercised }
    var currentWeight: Double { AppState.shared.currentWeight }
    var currentBMI: Double { AppState.shared.currentBMI }
    var todayMood: String { AppState.shared.todayMood }
    var habitsDone: Int { AppState.shared.todayHabitsDone }
    var habitsTotal: Int { AppState.shared.todayHabitsTotal }
    var dailyQuote: String { AppState.shared.dailyQuote }
    
    var isStudyDeleted: Bool { AppState.shared.studyModuleDeleted }
}
