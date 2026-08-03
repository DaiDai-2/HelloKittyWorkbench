import SwiftUI
import UniformTypeIdentifiers

/// 设置页面
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var showExportAlert = false
    @State private var showImportPicker = false
    @State private var exportMessage = ""
    @State private var waterReminderTime = Date()
    @State private var checkInReminderTime = Date()
    @State private var moodReminderTime = Date()
    @State private var waterReminderOn = false
    @State private var checkInReminderOn = false
    @State private var moodReminderOn = false
    
    var body: some View {
        NavigationView {
            Form {
                // 用户信息
                Section("个人资料") {
                    HStack {
                        Text("昵称")
                        Spacer()
                        Text(appState.userProfile.nickname)
                            .foregroundColor(HKColors.textSecondary)
                    }
                }
                
                // 外观
                Section("外观") {
                    Toggle("深色模式", isOn: $appState.isDarkMode)
                }
                
                // 云端同步
                Section("云端同步") {
                    HStack {
                        Image(systemName: appState.syncStatus.icon)
                            .foregroundColor(appState.syncStatus.color)
                        Text(appState.syncStatus.label)
                        Spacer()
                        if appState.syncStatus == .syncing {
                            ProgressView()
                        }
                    }
                    
                    if !appState.supabaseConfigured {
                        Button("配置Supabase连接") {
                            // 重置配置以显示设置页
                            dismiss()
                            appState.supabaseConfigured = false
                        }
                    }
                }
                
                // 通知设置
                Section("通知提醒") {
                    Toggle("饮水提醒", isOn: $waterReminderOn)
                        .onChange(of: waterReminderOn) { on in
                            if on {
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: waterReminderTime)
                                NotificationService.shared.scheduleWaterReminder(hour: comps.hour ?? 9, minute: comps.minute ?? 0)
                            } else {
                                NotificationService.shared.cancelReminder(identifier: "waterReminder")
                            }
                        }
                    if waterReminderOn {
                        DatePicker("提醒时间", selection: $waterReminderTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("打卡提醒", isOn: $checkInReminderOn)
                        .onChange(of: checkInReminderOn) { on in
                            if on {
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: checkInReminderTime)
                                NotificationService.shared.scheduleCheckInReminder(hour: comps.hour ?? 21, minute: comps.minute ?? 0)
                            } else {
                                NotificationService.shared.cancelReminder(identifier: "checkInReminder")
                            }
                        }
                    if checkInReminderOn {
                        DatePicker("提醒时间", selection: $checkInReminderTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("心情记录提醒", isOn: $moodReminderOn)
                        .onChange(of: moodReminderOn) { on in
                            if on {
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: moodReminderTime)
                                NotificationService.shared.scheduleMoodReminder(hour: comps.hour ?? 22, minute: comps.minute ?? 0)
                            } else {
                                NotificationService.shared.cancelReminder(identifier: "moodReminder")
                            }
                        }
                    if moodReminderOn {
                        DatePicker("提醒时间", selection: $moodReminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                // 数据管理
                Section("数据管理") {
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("导出数据 (JSON)")
                        }
                    }
                    
                    Button(action: { showImportPicker = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("导入数据 (JSON)")
                        }
                    }
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(HKColors.textSecondary)
                    }
                    Text("Hello Kitty 个人AI工作台")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                    Text("专为追求自律与成长的你设计 🎀")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .alert("数据导出", isPresented: $showExportAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(exportMessage)
            }
            .fileExporter(
                isPresented: $showExportAlert,
                document: JSONExportDocument(data: LocalStorageManager.shared.exportAllData() ?? Data()),
                contentType: .json,
                defaultFilename: "HelloKittyWorkbench_Backup_\(Date().hkDateString).json"
            ) { result in
                switch result {
                case .success:
                    exportMessage = "数据导出成功！"
                case .failure(let error):
                    exportMessage = "导出失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func exportData() {
        guard let data = LocalStorageManager.shared.exportAllData() else {
            exportMessage = "导出失败，没有数据"
            showExportAlert = true
            return
        }
        showExportAlert = true
    }
}

/// JSON导出文档
struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
