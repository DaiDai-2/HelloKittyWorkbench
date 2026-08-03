import SwiftUI

/// 心情日记视图
struct MoodTrackView: View {
    @EnvironmentObject var vm: MoodViewModel
    @State private var showAddMood = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("记录心情").tag(0)
                Text("心情日历").tag(1)
                Text("日记回顾").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                MoodRecordView(showAddMood: $showAddMood)
                    .tag(0)
                MoodCalendarView()
                    .tag(1)
                MoodDiaryListView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(HKColors.bgLight)
        .navigationTitle("😊 心情日记")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddMood = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddMood) {
            AddMoodView()
        }
    }
}

// MARK: - 记录心情
struct MoodRecordView: View {
    @EnvironmentObject var vm: MoodViewModel
    @Binding var showAddMood: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 今日心情
                if let todayMood = vm.todayMood {
                    VStack(spacing: 8) {
                        Text("今日心情")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                        Text(todayMood.moodLevel.rawValue)
                            .font(.system(size: 60))
                        Text(todayMood.moodLevel.label)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(HKColors.textPrimary)
                        if !todayMood.diary.isEmpty {
                            Text(todayMood.diary)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .hkPinkCard()
                } else {
                    VStack(spacing: 12) {
                        Text("今天还没有记录心情哦")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                        Button("记录今日心情") { showAddMood = true }
                            .hkPrimaryButton()
                    }
                    .hkCard()
                }
                
                // 心情统计
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 近7天心情分布")
                        .font(.system(.headline, design: .rounded))
                    
                    ForEach(vm.moodStats(days: 7), id: \.level) { stat in
                        HStack {
                            Text(stat.level.rawValue)
                                .font(.title3)
                            Text(stat.level.label)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                            Spacer()
                            Text("\(stat.count)天")
                                .font(.system(.caption, design: .rounded))
                            Text(String(format: "%.0f%%", stat.percentage))
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                                .frame(width: 45, alignment: .trailing)
                        }
                        
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: stat.level.color))
                                .frame(width: geo.size.width * CGFloat(stat.percentage / 100))
                        }
                        .frame(height: 6)
                    }
                }
                .hkCard()
                
                // 最近心情记录
                let recent = Array(vm.moodRecords.prefix(10))
                VStack(alignment: .leading, spacing: 8) {
                    Text("📝 最近记录")
                        .font(.system(.headline, design: .rounded))
                    
                    ForEach(recent) { record in
                        HStack {
                            Text(record.moodLevel.rawValue)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(record.moodLevel.label)
                                    .font(.system(.body, design: .rounded))
                                if !record.diary.isEmpty {
                                    Text(record.diary)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(HKColors.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text(record.date.hkDateString)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .contextMenu {
                            Button(role: .destructive) { vm.deleteMood(record) } label: {
                                Label("删除", systemImage: "trash")
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

// MARK: - 心情日历
struct MoodCalendarView: View {
    @EnvironmentObject var vm: MoodViewModel
    @State private var selectedMonth = Date()
    
    var body: some View {
        VStack {
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
            
            let days = generateMonthDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(["日","一","二","三","四","五","六"], id: \.self) { day in
                    Text(day).font(.system(.caption, design: .rounded)).foregroundColor(HKColors.textSecondary)
                }
                
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        let mood = vm.moodCalendarData[date.startOfDay]
                        VStack(spacing: 2) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(mood != nil ? .white : HKColors.textPrimary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(mood != nil ? Color(hex: mood!.color) : Color.clear)
                                )
                            
                            if let mood = mood {
                                Text(mood.rawValue)
                                    .font(.system(size: 10))
                            }
                        }
                    } else {
                        Color.clear.frame(width: 32, height: 38)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func generateMonthDays() -> [Date?] {
        let calendar = Calendar.current
        let start = selectedMonth.startOfMonth
        let daysInMonth = selectedMonth.daysInMonth
        let firstWeekday = calendar.component(.weekday, from: start)
        
        var result: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 1...daysInMonth {
            result.append(calendar.date(byAdding: .day, value: day - 1, to: start)!)
        }
        return result
    }
}

// MARK: - 日记回顾
struct MoodDiaryListView: View {
    @EnvironmentObject var vm: MoodViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 心情筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: { vm.selectedFilter = nil }) {
                        Text("全部")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(vm.selectedFilter == nil ? .white : HKColors.pinkDeep)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(vm.selectedFilter == nil ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    ForEach(MoodRecord.MoodLevel.allCases, id: \.self) { level in
                        Button(action: { vm.selectedFilter = level }) {
                            Text("\(level.rawValue) \(level.label)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(vm.selectedFilter == level ? .white : HKColors.pinkDeep)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(vm.selectedFilter == level ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            
            // 搜索
            TextField("搜索日记内容...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            List {
                let records = searchText.isEmpty ? vm.filteredRecords : vm.searchDiary(keyword: searchText)
                ForEach(records) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(record.moodLevel.rawValue)
                                .font(.title2)
                            Text(record.moodLevel.label)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()
                            Text(record.date.hkDateString)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                        
                        if !record.diary.isEmpty {
                            Text(record.diary)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(HKColors.textPrimary)
                        }
                        
                        if !record.tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(record.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundColor(HKColors.pinkDeep)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { _ in }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - 添加心情
struct AddMoodView: View {
    @EnvironmentObject var vm: MoodViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMood: MoodRecord.MoodLevel = .good
    @State private var diary = ""
    @State private var selectedTags: Set<String> = []
    @State private var newTag = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 心情选择
                VStack(spacing: 12) {
                    Text("今天心情如何？")
                        .font(.system(.headline, design: .rounded))
                    
                    HStack(spacing: 20) {
                        ForEach(MoodRecord.MoodLevel.allCases, id: \.self) { level in
                            Button(action: {
                                selectedMood = level
                                hkHaptic(.light)
                            }) {
                                VStack(spacing: 4) {
                                    Text(level.rawValue)
                                        .font(.system(size: 40))
                                        .scaleEffect(selectedMood == level ? 1.2 : 1.0)
                                        .animation(.spring(), value: selectedMood)
                                    Text(level.label)
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundColor(selectedMood == level ? HKColors.pinkDeep : HKColors.textSecondary)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMood == level ? HKColors.pinkDeep : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                }
                .hkCard()
                
                // 日记
                VStack(alignment: .leading, spacing: 8) {
                    Text("写点什么...")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                    
                    TextEditor(text: $diary)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .hkCard()
                
                // 标签
                VStack(alignment: .leading, spacing: 8) {
                    Text("添加标签")
                        .font(.system(.caption, design: .rounded))
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 6) {
                        ForEach(vm.allTags, id: \.self) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                Text("#\(tag)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(selectedTags.contains(tag) ? .white : HKColors.pinkDeep)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(selectedTags.contains(tag) ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("新标签", text: $newTag)
                            .textFieldStyle(.roundedBorder)
                        Button("添加") {
                            vm.addCustomTag(newTag)
                            selectedTags.insert(newTag)
                            newTag = ""
                        }
                        .font(.system(.caption, design: .rounded))
                        .disabled(newTag.isEmpty)
                    }
                }
                .hkCard()
                
                // 保存按钮
                Button(action: {
                    vm.addMood(level: selectedMood, diary: diary, tags: Array(selectedTags))
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("记录心情")
                    }
                    .frame(maxWidth: .infinity)
                    .hkPrimaryButton()
                }
            }
            .padding()
            .navigationTitle("记录心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
        }
    }
}
