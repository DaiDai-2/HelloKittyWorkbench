import SwiftUI

/// 学习目标视图（支持整体删除）
struct StudyGoalView: View {
    @EnvironmentObject var vm: StudyViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 删除模块按钮
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        vm.deleteModule()
                    } label: {
                        Label("删除此模块", systemImage: "trash")
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
                .padding(.top, 8)
                
                // 目标倒计时
                if let goal = vm.studyGoal {
                    VStack(spacing: 12) {
                        Text("\(vm.daysRemaining)")
                            .font(.system(size: 56, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(HKColors.pinkDeep)
                        Text("距离考试还有")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                        Text("天")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                        
                        if !goal.targetSchool.isEmpty {
                            Text("目标: \(goal.targetSchool) \(goal.targetMajor)")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(HKColors.textPrimary)
                        }
                    }
                    .hkPinkCard()
                    
                    // 编辑目标
                    EditStudyGoalView()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("还没有设置学习目标")
                            .foregroundColor(HKColors.textSecondary)
                        EditStudyGoalView()
                    }
                    .hkCard()
                }
                
                // 科目管理
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("📝 考试科目")
                            .font(.system(.headline, design: .rounded))
                        Spacer()
                        Button(action: {
                            // 添加科目
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(HKColors.pinkDeep)
                        }
                    }
                    
                    ForEach(vm.subjects) { subject in
                        SubjectProgressRow(subject: subject)
                    }
                    
                    AddSubjectView()
                }
                .hkCard()
                
                // 总体进度
                VStack(spacing: 12) {
                    Text("总体学习进度")
                        .font(.system(.headline, design: .rounded))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(HKColors.pinkLight.opacity(0.3))
                                .frame(height: 24)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [HKColors.pink, HKColors.pinkDeep]), startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: geo.size.width * CGFloat(vm.overallProgress), height: 24)
                        }
                    }
                    .frame(height: 24)
                    
                    Text("\(Int(vm.overallProgress * 100))%")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.pinkDeep)
                }
                .hkPinkCard()
            }
            .padding()
        }
        .background(HKColors.bgLight)
        .navigationTitle("📖 学习目标")
    }
}

// MARK: - 编辑学习目标
struct EditStudyGoalView: View {
    @EnvironmentObject var vm: StudyViewModel
    @State private var school = ""
    @State private var major = ""
    @State private var examDate = Date().addingTimeInterval(365 * 24 * 3600)
    @State private var showSheet = false
    
    var body: some View {
        Button(action: { showSheet = true }) {
            Text("设置/编辑学习目标")
                .font(.system(.caption, design: .rounded))
                .hkSecondaryButton()
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                Form {
                    TextField("目标院校", text: $school)
                    TextField("目标专业", text: $major)
                    DatePicker("考试日期", selection: $examDate, displayedComponents: .date)
                    Button("保存") {
                        vm.setStudyGoal(school: school, major: major, examDate: examDate)
                        showSheet = false
                    }
                }
                .navigationTitle("学习目标设置")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { showSheet = false } }
                }
            }
        }
    }
}

// MARK: - 科目进度行
struct SubjectProgressRow: View {
    let subject: ExamSubject
    @EnvironmentObject var vm: StudyViewModel
    @State private var progress: Double
    @State private var currentScore: String
    
    init(subject: ExamSubject) {
        self.subject = subject
        _progress = State(initialValue: subject.progress)
        _currentScore = State(initialValue: String(format: "%.0f", subject.currentScore))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(subject.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                Spacer()
                Text("目标: \(Int(subject.targetScore))分")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(HKColors.pinkLight.opacity(0.3))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(HKColors.pinkDeep)
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Slider(value: $progress, in: 0...1, step: 0.05)
                    .onChange(of: progress) { _ in
                        vm.updateSubjectProgress(subject, progress: progress, currentScore: Double(currentScore) ?? 0)
                    }
                Text("\(Int(progress * 100))%")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.pinkDeep)
                    .frame(width: 40)
            }
            
            HStack {
                TextField("当前模拟分", text: $currentScore)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.caption, design: .rounded))
                    .onChange(of: currentScore) { _ in
                        vm.updateSubjectProgress(subject, progress: progress, currentScore: Double(currentScore) ?? 0)
                    }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contextMenu {
            Button(role: .destructive) {
                vm.deleteSubject(subject)
            } label: {
                Label("删除科目", systemImage: "trash")
            }
        }
    }
}

// MARK: - 添加科目
struct AddSubjectView: View {
    @EnvironmentObject var vm: StudyViewModel
    @State private var name = ""
    @State private var targetScore = "100"
    
    var body: some View {
        HStack {
            TextField("科目名称", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("目标分", text: $targetScore)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(width: 70)
            Button("添加") {
                guard !name.isEmpty else { return }
                vm.addSubject(name: name, targetScore: Double(targetScore) ?? 100)
                name = ""
                targetScore = "100"
            }
            .font(.system(.caption, design: .rounded))
            .hkSecondaryButton()
            .disabled(name.isEmpty)
        }
    }
}
