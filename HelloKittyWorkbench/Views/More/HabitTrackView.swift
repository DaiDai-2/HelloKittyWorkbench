import SwiftUI

/// 计划打卡视图
struct HabitTrackView: View {
    @EnvironmentObject var vm: HabitViewModel
    @State private var showAddPlan = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("今日打卡").tag(0)
                Text("所有计划").tag(1)
                Text("热力图").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                TodayCheckInView(showAddPlan: $showAddPlan)
                    .tag(0)
                AllPlansView()
                    .tag(1)
                HeatmapView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(HKColors.bgLight)
        .navigationTitle("📋 计划打卡")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddPlan = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddPlan) {
            AddHabitPlanView()
        }
    }
}

// MARK: - 今日打卡
struct TodayCheckInView: View {
    @EnvironmentObject var vm: HabitViewModel
    @Binding var showAddPlan: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if vm.todayPlans.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(HKColors.textSecondary)
                        Text("今天没有需要打卡的计划")
                            .foregroundColor(HKColors.textSecondary)
                        Button("创建计划") { showAddPlan = true }
                            .hkSecondaryButton()
                    }
                    .padding(.vertical, 60)
                }
                
                ForEach(vm.todayPlans) { plan in
                    let isChecked = vm.isCheckedInToday(planId: plan.id)
                    
                    Button(action: {
                        if isChecked {
                            vm.undoCheckIn(for: plan)
                        } else {
                            vm.checkIn(for: plan)
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plan.name)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                Text("连续 \(vm.streakDays(for: plan)) 天")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(isChecked ? HKColors.pinkDeep : Color.gray.opacity(0.3), lineWidth: 3)
                                    .frame(width: 40, height: 40)
                                
                                if isChecked {
                                    Image(systemName: "checkmark")
                                        .font(.system(.body, weight: .bold))
                                        .foregroundColor(HKColors.pinkDeep)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

// MARK: - 所有计划
struct AllPlansView: View {
    @EnvironmentObject var vm: HabitViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(vm.plans) { plan in
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(plan.name)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                Text(plan.frequency.label)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            Spacer()
                            
                            if plan.isPaused {
                                Text("已暂停")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        HStack {
                            Text("完成率: \(Int(vm.completionRate(for: plan) * 100))%")
                                .font(.system(.caption, design: .rounded))
                            Spacer()
                            Text("连续: \(vm.streakDays(for: plan))天")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.pinkDeep)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: { vm.togglePause(plan) }) {
                                Text(plan.isPaused ? "恢复" : "暂停")
                                    .font(.system(.caption, design: .rounded))
                                    .hkSecondaryButton()
                            }
                            
                            Button(role: .destructive) {
                                vm.deletePlan(plan)
                            } label: {
                                Text("删除")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .hkCard()
                }
                
                if vm.plans.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("还没有计划")
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding()
        }
    }
}

// MARK: - 热力图
struct HeatmapView: View {
    @EnvironmentObject var vm: HabitViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("📊 打卡热力图")
                    .font(.system(.headline, design: .rounded))
                
                Text("最近90天打卡情况")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
                
                let data = vm.heatmapData
                let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
                
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(data, id: \.date) { item in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(heatmapColor(item.count))
                            .frame(height: 16)
                    }
                }
                .padding()
                
                HStack(spacing: 4) {
                    Text("少")
                        .font(.system(.caption2, design: .rounded))
                    ForEach(0..<5) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(heatmapColor(i))
                            .frame(width: 14, height: 14)
                    }
                    Text("多")
                        .font(.system(.caption2, design: .rounded))
                }
            }
            .padding()
        }
    }
    
    private func heatmapColor(_ count: Int) -> Color {
        switch count {
        case 0: return HKColors.pinkLight.opacity(0.1)
        case 1: return HKColors.pinkLight.opacity(0.3)
        case 2: return HKColors.pink.opacity(0.5)
        case 3: return HKColors.pink.opacity(0.7)
        default: return HKColors.pinkDeep
        }
    }
}

// MARK: - 添加计划
struct AddHabitPlanView: View {
    @EnvironmentObject var vm: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var frequencyType = 0 // 0:daily, 1:weekly, 2:custom
    @State private var weeklyCount = 3
    @State private var customDays = 3
    
    var body: some View {
        NavigationView {
            Form {
                TextField("计划名称", text: $name)
                
                Section("频率") {
                    Picker("频率", selection: $frequencyType) {
                        Text("每天").tag(0)
                        Text("每周X次").tag(1)
                        Text("自定义").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                    if frequencyType == 1 {
                        Stepper("每周 \(weeklyCount) 次", value: $weeklyCount, in: 1...7)
                    } else if frequencyType == 2 {
                        Stepper("每 \(customDays) 天", value: $customDays, in: 2...30)
                    }
                }
                
                Button("创建计划") {
                    guard !name.isEmpty else { return }
                    let freq: HabitPlan.HabitFrequency = {
                        switch frequencyType {
                        case 1: return .weekly(weeklyCount)
                        case 2: return .custom(customDays)
                        default: return .daily
                        }
                    }()
                    vm.addPlan(name: name, frequency: freq)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle("创建计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
        }
    }
}
