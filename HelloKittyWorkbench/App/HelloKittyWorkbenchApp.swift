import SwiftUI
import CoreData

@main
struct HelloKittyWorkbenchApp: App {
    @StateObject private var syncService = DataSyncService.shared
    @StateObject private var appState = AppState.shared
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(syncService)
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : nil)
                .onAppear {
                    NotificationService.shared.requestAuthorization()
                    syncService.startAutoSync()
                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        syncService.syncAllData()
                    case .background:
                        persistenceController.saveContext()
                    default:
                        break
                    }
                }
        }
    }
}
