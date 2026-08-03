import SwiftUI

/// 健康模块主页
struct HealthView: View {
    @EnvironmentObject var exerciseVM: ExerciseViewModel
    @EnvironmentObject var weightVM: WeightViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("运动打卡").tag(0)
                Text("体重记录").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                ExerciseView()
                    .tag(0)
                WeightTrackView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(HKColors.bgLight.ignoresSafeArea())
        .navigationTitle("🏋️ 健康运动")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 运动打卡
struct ExerciseView: View {
    @EnvironmentObject var vm: ExerciseViewModel
    @State private var showAddExercise = false
    @State private var showCalendar = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 统计卡片
                statsCard
                
                // 本周/本月统计
                statisticsCard
                
                // 日历视图按钮
                Button(action: { showCalendar = true }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("查看打卡日历")
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(HKColors.pinkDeep)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(HKColors.pinkLight.opacity(0.2))
                    .cornerRadius(16)
                }
                
                // 运动记录列表
                let recentRecords = vm.exerciseRecords.sorted(by: { $0.date > $1.date }).prefix(20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 运动记录")
                        .font(.system(.headline, design: .rounded))
                    
                    ForEach(Array(recentRecords)) { record in
                        HStack {
                            Image(systemName: record.type == .cardio ? "heart.circle.fill" : (record.type == .strength ? "dumbbell.fill" : "figure.mind.and.body"))
                                .foregroundColor(record.type == .cardio ? .red : (record.type == .strength ? .orange : .purple))
                            
                            VStack(alignment: .leading) {
                                Text(record.exerciseName)
                                    .font(.system(.body, design: .rounded))
                                Text("\(Int(record.duration))分钟 · \(Int(record.caloriesBurned))kcal")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            Spacer()
                            Text(record.date.hkDateString)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteExercise(record)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
                .hkCard()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddExercise = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseView()
        }
        .sheet(isPresented: $showCalendar) {
            ExerciseCalendarView()
        }
    }
    
    private var statsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
                Text("连续打卡")
                    .font(.system(.subheadline, design: .rounded))
                Text("\(vm.streakDays) 天")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(HKColors.pinkDeep)
                Spacer()
                Text(vm.todayExercised ? "✅" : "⏳")
                    .font(.title2)
            }
        }
        .hkPinkCard()
    }
    
    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 本周统计")
                .font(.system(.headline, design: .rounded))
            
            HStack(spacing: 0) {
                statItem(title: "运动次数", value: "\(vm.weekCount)")
                statItem(title: "总时长", value: "\(Int(vm.weekDuration))min")
                statItem(title: "总消耗", value: "\(Int(vm.weekCalories))kcal")
            }
            
            Divider()
            
            Text("📊 本月统计")
                .font(.system(.headline, design: .rounded))
            
            HStack(spacing: 0) {
                statItem(title: "运动次数", value: "\(vm.monthCount)")
                statItem(title: "总时长", value: "\(Int(vm.monthDuration))min")
                statItem(title: "总消耗", value: "\(Int(vm.monthCalories))kcal")
            }
        }
        .hkCard()
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(HKColors.pinkDeep)
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HKColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 添加运动
struct AddExerciseView: View {
    @EnvironmentObject var vm: ExerciseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: ExerciseRecord.ExerciseType = .cardio
    @State private var exerciseName = ""
    @State private var duration = ""
    @State private var calories = ""
    @State private var note = ""
    @State private var date = Date()
    
    var exerciseOptions: [String] {
        switch selectedType {
        case .cardio: return vm.cardioExercises
        case .strength: return vm.strengthExercises
        case .other: return vm.otherExercises
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("运动类型") {
                    Picker("类型", selection: $selectedType) {
                        ForEach(ExerciseRecord.ExerciseType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("运动项目") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(exerciseOptions, id: \.self) { option in
                                Button(action: { exerciseName = option }) {
                                    Text(option)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(exerciseName == option ? .white : HKColors.pinkDeep)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(exerciseName == option ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    TextField("或手动输入运动名称", text: $exerciseName)
                }
                
                Section("运动数据") {
                    TextField("时长 (分钟)", text: $duration)
                        .keyboardType(.decimalPad)
                    TextField("消耗卡路里 (可选，留空自动估算)", text: $calories)
                        .keyboardType(.decimalPad)
                }
                
                Section("备注") {
                    TextField("今天深蹲加了5kg...", text: $note)
                }
                
                Section("日期") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveExercise) {
                        HStack {
                            Spacer()
                            Text("记录运动")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(exerciseName.isEmpty || duration.isEmpty)
                }
            }
            .navigationTitle("记录运动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
        }
    }
    
    private func saveExercise() {
        guard let dur = Double(duration), !exerciseName.isEmpty else { return }
        let cal = Double(calories)
        vm.addExercise(type: selectedType, name: exerciseName, duration: dur, calories: cal, note: note, date: date)
        dismiss()
    }
}

// MARK: - 运动日历
struct ExerciseCalendarView: View {
    @EnvironmentObject var vm: ExerciseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedMonth = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // 月份选择
                HStack {
                    Button(action: {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(selectedMonth, format: .dateTime.year().month())
                        .font(.system(.headline, design: .rounded))
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // 日历网格
                let days = generateMonthDays()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                        Text(day)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    
                    ForEach(days.indices, id: \.self) { index in
                        if let date = days[index] {
                            let hasExercise = vm.checkInDates.contains(date.startOfDay)
                            VStack(spacing: 2) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(hasExercise ? .white : HKColors.textPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(hasExercise ? HKColors.pinkDeep : Color.clear)
                                    .clipShape(Circle())
                                
                                if hasExercise {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(HKColors.pink)
                                }
                            }
                        } else {
                            Color.clear.frame(width: 32, height: 32)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("运动日历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } }
            }
        }
    }
    
    private func generateMonthDays() -> [Date?] {
        let calendar = Calendar.current
        let start = selectedMonth.startOfMonth
        let daysInMonth = selectedMonth.daysInMonth
        let firstWeekday = calendar.component(.weekday, from: start)
        
        var result: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            let date = calendar.date(byAdding: .day, value: day - 1, to: start)!
            result.append(date)
        }
        
        return result
    }
}

// MARK: - 体重记录页
struct WeightTrackView: View {
    @EnvironmentObject var vm: WeightViewModel
    @State private var showAddWeight = false
    @State private var showProfileEdit = false
    @State private var selectedRange = 0 // 0: 7天, 1: 30天, 2: 全部
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 体重/BMI卡片
                VStack(spacing: 16) {
                    if let weight = vm.latestWeight {
                        Text("\(String(format: "%.1f", weight))")
                            .font(.system(size: 48, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(HKColors.pinkDeep)
                        Text("kg")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    } else {
                        Text("--")
                            .font(.system(size: 48, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(HKColors.textSecondary)
                        Text("还没有体重记录")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    
                    HStack(spacing: 12) {
                        bmiCard
                        if let bf = vm.estimatedBodyFat {
                            statMiniCard(title: "体脂率", value: String(format: "%.1f%%", bf))
                        }
                    }
                }
                .hkPinkCard()
                
                // 标准体重
                let ideal = vm.idealWeight
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎯 标准体重范围: \(String(format: "%.1f", ideal.min)) - \(String(format: "%.1f", ideal.max)) kg")
                        .font(.system(.body, design: .rounded))
                    if let weight = vm.latestWeight {
                        Text(weight > ideal.max ? "⚠️ 高于标准范围" : (weight < ideal.min ? "⚠️ 低于标准范围" : "✅ 在标准范围内"))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(weight > ideal.max || weight < ideal.min ? .orange : .green)
                    }
                }
                .hkCard()
                
                // 趋势图（文字列表形式）
                VStack(alignment: .leading, spacing: 8) {
                    Picker("范围", selection: $selectedRange) {
                        Text("7天").tag(0)
                        Text("30天").tag(1)
                        Text("全部").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                    let days = selectedRange == 0 ? 7 : (selectedRange == 1 ? 30 : nil)
                    let trendData: [(date: Date, weight: Double)] = {
                        if let d = days {
                            return vm.weightTrendData(days: d)
                        }
                        return vm.weightRecords.sorted { $0.date < $1.date }.map { ($0.date, $0.weight) }
                    }()
                    
                    // 简易折线图
                    if !trendData.isEmpty {
                        VStack(spacing: 8) {
                            HStack(alignment: .bottom, spacing: 2) {
                                ForEach(trendData.indices, id: \.self) { index in
                                    let maxWeight = trendData.map(\.weight).max() ?? 1
                                    let minWeight = trendData.map(\.weight).min() ?? 0
                                    let range = max(1, maxWeight - minWeight)
                                    let height = max(20, 80 * (trendData[index].weight - minWeight) / range)
                                    
                                    VStack {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(HKColors.pinkDeep)
                                            .frame(height: CGFloat(height))
                                    }
                                }
                            }
                            .frame(height: 80)
                            
                            Text("趋势范围: \(String(format: "%.1f", trendData.map(\.weight).min() ?? 0)) - \(String(format: "%.1f", trendData.map(\.weight).max() ?? 0)) kg")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                    } else {
                        Text("暂无数据")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                            .padding(.vertical, 20)
                    }
                }
                .hkCard()
                
                // 历史记录
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 历史记录")
                        .font(.system(.headline, design: .rounded))
                    
                    ForEach(vm.weightRecords.prefix(30)) { record in
                        HStack {
                            Text("\(String(format: "%.1f", record.weight)) kg")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()
                            Text(record.date.hkDateString)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteWeight(record)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
                .hkCard()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: { showProfileEdit = true }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(HKColors.pinkDeep)
                    }
                    Button(action: { showAddWeight = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(HKColors.pinkDeep)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddWeight) {
            AddWeightView()
        }
        .sheet(isPresented: $showProfileEdit) {
            WeightProfileEditView()
        }
    }
    
    private var bmiCard: some View {
        VStack(spacing: 4) {
            if let bmi = vm.bmi {
                Text(String(format: "%.1f", bmi))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: vm.bmiColor))
                Text("BMI")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
                Text(vm.bmiCategory)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(Color(hex: vm.bmiColor))
            } else {
                Text("--")
                    .font(.system(.title3, design: .rounded))
                Text("BMI")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(HKColors.pinkLight.opacity(0.2))
        .cornerRadius(12)
    }
    
    private func statMiniCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(HKColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(HKColors.pinkLight.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - 添加体重 / 编辑资料
struct AddWeightView: View {
    @EnvironmentObject var vm: WeightViewModel
    @Environment(\.dismiss) var dismiss
    @State private var weight = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("体重 (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                DatePicker("日期", selection: $date, displayedComponents: .date)
                Button("记录") {
                    guard let w = Double(weight) else { return }
                    vm.addWeight(w, date: date)
                    dismiss()
                }
                .disabled(weight.isEmpty)
            }
            .navigationTitle("记录体重")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
        }
    }
}

struct WeightProfileEditView: View {
    @EnvironmentObject var vm: WeightViewModel
    @Environment(\.dismiss) var dismiss
    @State private var gender: UserProfile.Gender = .female
    @State private var height = ""
    @State private var birthYear = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("性别", selection: $gender) {
                    ForEach(UserProfile.Gender.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                TextField("身高 (cm)", text: $height)
                    .keyboardType(.decimalPad)
                TextField("出生年份", text: $birthYear)
                    .keyboardType(.numberPad)
                Button("保存") {
                    vm.userProfile.gender = gender
                    if let h = Double(height) { vm.userProfile.height = h }
                    if let y = Int(birthYear) { vm.userProfile.birthYear = y }
                    vm.saveProfile()
                    dismiss()
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
            .onAppear {
                gender = vm.userProfile.gender
                height = String(format: "%.0f", vm.userProfile.height)
                birthYear = "\(vm.userProfile.birthYear)"
            }
        }
    }
}
