import SwiftUI

/// 饮食管理主页
struct DietView: View {
    @EnvironmentObject var vm: DietViewModel
    @State private var selectedTab = 0
    @State private var showAddFood = false
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部选择器
            Picker("", selection: $selectedTab) {
                Text("热量查询").tag(0)
                Text("今日记录").tag(1)
                Text("饮水记录").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                CalorieQueryView()
                    .tag(0)
                TodayDietListView(selectedDate: $selectedDate)
                    .tag(1)
                WaterTrackView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(HKColors.bgLight.ignoresSafeArea())
        .navigationTitle("🍽️ 饮食管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddFood = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddFood) {
            ManualAddFoodView()
        }
    }
}

// MARK: - 热量查询页
struct CalorieQueryView: View {
    @EnvironmentObject var vm: DietViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(HKColors.pinkDeep)
                    TextField("输入食物名称，如：一个苹果、一碗米饭", text: $vm.searchQuery)
                        .font(.system(.body, design: .rounded))
                        .onSubmit { vm.searchFood() }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                Button(action: vm.searchFood) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("查询热量")
                    }
                    .frame(maxWidth: .infinity)
                    .hkPrimaryButton()
                }
                
                // 搜索结果
                if let result = vm.searchResult {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                Text("参考份量: \(result.portion)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            Spacer()
                            Text("\(Int(result.calories)) kcal")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(HKColors.pinkDeep)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                vm.addDietRecord(foodName: result.name, calories: result.calories, portion: result.portion, mealType: "snack")
                            }) {
                                Label("加入记录", systemImage: "plus.circle.fill")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(HKColors.pinkDeep)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .hkPinkCard()
                }
                
                if vm.showNotFound {
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("未找到该食物")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                        Text("请手动添加热量信息")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .hkCard()
                }
                
                // 热门食物快速查询
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 常见食物快速查询")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(["一碗米饭", "一个苹果", "一个鸡蛋", "一杯牛奶", "一根香蕉", "一杯奶茶", "一碗面条", "一片全麦面包"], id: \.self) { food in
                            Button(action: {
                                vm.searchQuery = food
                                vm.searchFood()
                            }) {
                                Text(food)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.pinkDeep)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(HKColors.pinkLight.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .hkCard()
            }
            .padding()
        }
    }
}

// MARK: - 今日饮食记录
struct TodayDietListView: View {
    @EnvironmentObject var vm: DietViewModel
    @Binding var selectedDate: Date
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 日期选择
                DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                
                let records = vm.dietRecordsFor(date: selectedDate)
                
                // 总热量
                VStack(spacing: 4) {
                    Text("\(Int(records.reduce(0) { $0 + $1.calories }))")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.pinkDeep)
                    Text("总摄入 (kcal)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .hkPinkCard()
                
                if records.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("今天还没有饮食记录")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .padding(.vertical, 40)
                }
                
                // 饮食列表（按餐次分组）
                ForEach(["breakfast": "🌅 早餐", "lunch": "☀️ 午餐", "dinner": "🌙 晚餐", "snack": "🍪 零食"], id: \.key) { mealType, label in
                    let mealRecords = records.filter { $0.mealType == mealType }
                    if !mealRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(label)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(HKColors.textPrimary)
                            
                            ForEach(mealRecords) { record in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(record.foodName)
                                            .font(.system(.body, design: .rounded))
                                        Text("\(record.portion) · \(record.date.hkTimeString)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(HKColors.textSecondary)
                                    }
                                    Spacer()
                                    Text("\(Int(record.calories)) kcal")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(HKColors.pinkDeep)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        vm.deleteDietRecord(record)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .hkCard()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - 饮水记录
struct WaterTrackView: View {
    @EnvironmentObject var vm: DietViewModel
    @State private var showGoalSetting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 饮水进度
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(HKColors.pinkLight.opacity(0.3), lineWidth: 16)
                            .frame(width: 180, height: 180)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(vm.waterProgress))
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [HKColors.pink, HKColors.pinkDeep]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: vm.waterProgress)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(vm.todayWaterTotal))")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(HKColors.pinkDeep)
                            Text("/ \(Int(vm.waterGoal)) ml")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                    }
                    
                    Text("\(Int(vm.waterProgress * 100))% 完成")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(HKColors.textPrimary)
                }
                .hkPinkCard()
                
                // 快捷加水按钮
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        waterButton(amount: 100, label: "100ml")
                        waterButton(amount: 250, label: "一杯水", isMain: true)
                        waterButton(amount: 500, label: "500ml")
                    }
                    
                    HStack(spacing: 16) {
                        waterButton(amount: 350, label: "一瓶小")
                        waterButton(amount: 550, label: "一瓶大")
                        waterButton(amount: 1000, label: "1L")
                    }
                }
                
                // 自定义目标
                Button(action: { showGoalSetting = true }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("自定义目标: \(Int(vm.waterGoal))ml")
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
                }
                .sheet(isPresented: $showGoalSetting) {
                    waterGoalSheet
                }
                
                // 今日饮水记录列表
                let todayWaterRecords = vm.waterRecords
                    .filter { $0.date.startOfDay == Date().startOfDay }
                    .sorted { $0.date > $1.date }
                
                if !todayWaterRecords.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📋 今日饮水记录")
                            .font(.system(.headline, design: .rounded))
                        
                        ForEach(todayWaterRecords) { record in
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                Text("+\(Int(record.amount))ml")
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                                Text(record.date.hkTimeString)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                    }
                    .hkCard()
                }
            }
            .padding()
        }
    }
    
    private func waterButton(amount: Double, label: String, isMain: Bool = false) -> some View {
        Button(action: {
            vm.addWater(amount: amount)
        }) {
            VStack(spacing: 4) {
                Image(systemName: isMain ? "drop.fill" : "drop")
                    .font(.title3)
                Text(label)
                    .font(.system(.caption, design: .rounded))
            }
            .foregroundColor(isMain ? .white : HKColors.pinkDeep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isMain ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
            .cornerRadius(16)
        }
    }
    
    private var waterGoalSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("设置每日饮水目标")
                    .font(.system(.headline, design: .rounded))
                
                HStack {
                    Slider(value: Binding(
                        get: { vm.waterGoal },
                        set: { vm.setWaterGoal($0) }
                    ), in: 500...5000, step: 250)
                    
                    Text("\(Int(vm.waterGoal))ml")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.pinkDeep)
                        .frame(width: 70)
                }
                .padding()
                
                Text("建议每天饮用1500-2000ml水")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
            }
            .padding()
            .navigationTitle("饮水目标")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 手动添加食物
struct ManualAddFoodView: View {
    @EnvironmentObject var vm: DietViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var portion = "一份"
    @State private var mealType = "snack"
    
    let mealTypes = [("breakfast", "早餐"), ("lunch", "午餐"), ("dinner", "晚餐"), ("snack", "零食")]
    
    var body: some View {
        NavigationView {
            Form {
                Section("食物信息") {
                    TextField("食物名称", text: $foodName)
                    TextField("热量 (kcal)", text: $calories)
                        .keyboardType(.decimalPad)
                    TextField("份量", text: $portion)
                }
                
                Section("餐次") {
                    Picker("餐次", selection: $mealType) {
                        ForEach(mealTypes, id: \.0) { type, label in
                            Text(label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(action: addFood) {
                        HStack {
                            Spacer()
                            Label("添加记录", systemImage: "plus.circle.fill")
                            Spacer()
                        }
                    }
                    .disabled(foodName.isEmpty || calories.isEmpty)
                }
            }
            .navigationTitle("手动添加食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
    
    private func addFood() {
        guard let cal = Double(calories), !foodName.isEmpty else { return }
        vm.addDietRecord(foodName: foodName, calories: cal, portion: portion, mealType: mealType)
        dismiss()
    }
}
