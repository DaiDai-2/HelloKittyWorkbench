import Foundation
import Combine

/// 数据同步服务 - 管理本地与Supabase同步
class DataSyncService: ObservableObject {
    static let shared = DataSyncService()
    
    @Published var isSyncing = false
    private var syncTimer: Timer?
    private var pendingSyncItems: [String: [Any]] = [:]
    
    private init() {}
    
    func startAutoSync() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.syncAllData()
        }
        // 首次立即同步
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.syncAllData()
        }
    }
    
    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    /// 同步所有数据到Supabase
    func syncAllData() {
        guard SupabaseService.shared.connected else {
            DispatchQueue.main.async {
                AppState.shared.syncStatus = .disconnected
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            AppState.shared.syncStatus = .syncing
        }
        
        Task {
            do {
                try await syncTable("diet_records", items: LocalStorageManager.shared.loadDietRecords())
                try await syncTable("water_records", items: LocalStorageManager.shared.loadWaterRecords())
                try await syncTable("transactions", items: LocalStorageManager.shared.loadTransactions())
                try await syncTable("categories", items: LocalStorageManager.shared.loadCategories())
                try await syncTable("budget_plans", items: LocalStorageManager.shared.loadBudgetPlans())
                try await syncTable("debts", items: LocalStorageManager.shared.loadDebts())
                try await syncTable("savings_goals", items: LocalStorageManager.shared.loadSavingsGoals())
                try await syncTable("exercise_records", items: LocalStorageManager.shared.loadExerciseRecords())
                try await syncTable("weight_records", items: LocalStorageManager.shared.loadWeightRecords())
                try await syncTable("books", items: LocalStorageManager.shared.loadBooks())
                try await syncTable("reading_notes", items: LocalStorageManager.shared.loadReadingNotes())
                try await syncTable("habit_plans", items: LocalStorageManager.shared.loadHabitPlans())
                try await syncTable("habit_checkins", items: LocalStorageManager.shared.loadHabitCheckIns())
                try await syncTable("mood_records", items: LocalStorageManager.shared.loadMoodRecords())
                
                await MainActor.run {
                    AppState.shared.syncStatus = .connected
                    self.isSyncing = false
                }
            } catch {
                await MainActor.run {
                    AppState.shared.syncStatus = .disconnected
                    self.isSyncing = false
                    print("同步失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func syncTable<T: Codable & Identifiable>(_ table: String, items: [T]) async throws where T.ID == UUID {
        guard SupabaseService.shared.connected else { return }
        
        // 上传播未同步的数据
        let unsyncedItems = items.filter { item in
            if let syncable = item as? (any HasSyncStatus) {
                return !syncable.isSynced
            }
            return true
        }
        
        for item in unsyncedItems {
            try await SupabaseService.shared.update(item, table: table)
        }
        
        // 下载云端数据并合并
        let cloudItems: [T] = try await SupabaseService.shared.fetch(table: table)
        var mergedItems = items
        
        for cloudItem in cloudItems {
            if !mergedItems.contains(where: { $0.id == cloudItem.id }) {
                mergedItems.append(cloudItem)
            }
        }
        
        // 保存合并后的数据到本地（这里不直接save，由各ViewModel自行处理）
    }
    
    /// 标记需要同步
    func markNeedsSync(table: String) {
        // 触发即时同步
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.syncAllData()
        }
    }
}

/// 同步状态辅助协议
protocol HasSyncStatus {
    var isSynced: Bool { get }
}
