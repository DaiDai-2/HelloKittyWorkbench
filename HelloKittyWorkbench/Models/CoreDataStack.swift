import CoreData
import Foundation

/// Core Data 管理器 - 单例模式
class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HelloKittyWorkbench")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data加载失败: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Core Data保存失败: \(error.localizedDescription)")
        }
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}

// MARK: - 同步状态标记协议
protocol SyncableEntity {
    var id: UUID? { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var isSynced: Bool { get set }
}
