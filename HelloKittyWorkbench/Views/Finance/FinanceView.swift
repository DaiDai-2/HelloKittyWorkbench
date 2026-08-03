import SwiftUI

/// 资金管理主页
struct FinanceView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @State private var selectedTab = 0
    @State private var showAddTransaction = false
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("收支").tag(0)
                Text("规划").tag(1)
                Text("欠款").tag(2)
                Text("存钱").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                TransactionListView(showAddTransaction: $showAddTransaction)
                    .tag(0)
                BudgetPlanView()
                    .tag(1)
                DebtListView()
                    .tag(2)
                SavingsGoalListView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(HKColors.bgLight.ignoresSafeArea())
        .navigationTitle("💰 资金管理")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedTab == 0 {
                    Button(action: { showAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(HKColors.pinkDeep)
                    }
                }
            }
        }
    }
}

// MARK: - 收支记录
struct TransactionListView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @Binding var showAddTransaction: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 月度概览
                VStack(spacing: 16) {
                    HStack {
                        summaryBlock(title: "本月收入", amount: vm.monthIncome, color: .green)
                        Divider()
                        summaryBlock(title: "本月支出", amount: vm.monthExpense, color: .red)
                        Divider()
                        summaryBlock(title: "结余", amount: vm.monthIncome - vm.monthExpense, color: HKColors.pinkDeep)
                    }
                }
                .hkPinkCard()
                
                // 支出分类饼图（文字版）
                if !vm.expenseByCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 支出分类占比")
                            .font(.system(.headline, design: .rounded))
                        
                        ForEach(Array(vm.expenseByCategory.prefix(8)), id: \.category) { item in
                            let percentage = vm.monthExpense > 0 ? item.amount / vm.monthExpense * 100 : 0
                            VStack(spacing: 4) {
                                HStack {
                                    Text(item.category)
                                        .font(.system(.caption, design: .rounded))
                                    Spacer()
                                    Text("¥\(String(format: "%.0f", item.amount)) (\(String(format: "%.0f", percentage))%)")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(HKColors.textSecondary)
                                }
                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(HKColors.pinkDeep)
                                        .frame(width: geo.size.width * CGFloat(percentage / 100))
                                }
                                .frame(height: 8)
                                .background(HKColors.pinkLight.opacity(0.2))
                                .cornerRadius(4)
                            }
                        }
                    }
                    .hkCard()
                }
                
                // 交易列表
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 最近交易")
                        .font(.system(.headline, design: .rounded))
                    
                    ForEach(vm.transactions.sorted(by: { $0.date > $1.date }).prefix(30)) { record in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(record.category)
                                    .font(.system(.body, design: .rounded))
                                if !record.note.isEmpty {
                                    Text(record.note)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(HKColors.textSecondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(record.type == .income ? "+" : "-")¥\(String(format: "%.2f", record.amount))")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(record.type == .income ? .green : .red)
                                Text(record.date.hkDateString)
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteTransaction(record)
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
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func summaryBlock(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HKColors.textSecondary)
            Text("¥\(String(format: "%.0f", amount))")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - 添加交易
struct AddTransactionView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isIncome = false
    @State private var amount = ""
    @State private var selectedCategory = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var showCategoryManager = false
    
    var categories: [CategoryItem] {
        isIncome ? vm.incomeCategories : vm.expenseCategories
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("类型") {
                    Picker("类型", selection: $isIncome) {
                        Text("支出").tag(false)
                        Text("收入").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("金额") {
                    HStack {
                        Text("¥")
                            .font(.title2)
                            .foregroundColor(HKColors.textSecondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(.title2, design: .rounded))
                    }
                }
                
                Section("分类") {
                    if categories.isEmpty {
                        Button("添加分类") { showCategoryManager = true }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories) { category in
                                    Button(action: { selectedCategory = category.name }) {
                                        Text(category.name)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(selectedCategory == category.name ? .white : HKColors.pinkDeep)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category.name ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        Button("管理分类") { showCategoryManager = true }
                            .font(.system(.caption, design: .rounded))
                    }
                }
                
                Section("备注") {
                    TextField("添加备注", text: $note)
                }
                
                Section("日期") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveTransaction) {
                        HStack {
                            Spacer()
                            Text(isIncome ? "记录收入" : "记录支出")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(amount.isEmpty || selectedCategory.isEmpty)
                }
            }
            .navigationTitle(isIncome ? "添加收入" : "添加支出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .sheet(isPresented: $showCategoryManager) {
                CategoryManagerView(isIncome: isIncome)
            }
            .onChange(of: isIncome) { _ in selectedCategory = "" }
        }
    }
    
    private func saveTransaction() {
        guard let amt = Double(amount), !selectedCategory.isEmpty else { return }
        vm.addTransaction(
            type: isIncome ? .income : .expense,
            amount: amt,
            category: selectedCategory,
            note: note,
            date: date
        )
        dismiss()
    }
}

// MARK: - 分类管理
struct CategoryManagerView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    @State var isIncome: Bool
    @State private var newCategoryName = ""
    
    var categories: [CategoryItem] {
        isIncome ? vm.incomeCategories : vm.expenseCategories
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("现有分类") {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            vm.deleteCategory(categories[index])
                        }
                    }
                }
                
                Section("添加新分类") {
                    HStack {
                        TextField("分类名称", text: $newCategoryName)
                        Button("添加") {
                            guard !newCategoryName.isEmpty else { return }
                            vm.addCategory(name: newCategoryName, type: isIncome ? "income" : "expense")
                            newCategoryName = ""
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .navigationTitle("管理分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 支出规划
struct BudgetPlanView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @State private var salary = ""
    @State private var needs = 50.0
    @State private var wants = 30.0
    @State private var savings = 20.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 设置
                VStack(alignment: .leading, spacing: 12) {
                    Text("📝 设置月工资")
                        .font(.system(.headline, design: .rounded))
                    
                    HStack {
                        Text("¥")
                        TextField("月工资", text: $salary)
                            .keyboardType(.decimalPad)
                            .font(.system(.body, design: .rounded))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    Button("应用50/30/20法则") {
                        guard let sal = Double(salary) else { return }
                        vm.setBudgetPlan(salary: sal)
                    }
                    .frame(maxWidth: .infinity)
                    .hkPrimaryButton()
                }
                .hkCard()
                
                // 规划结果
                if let plan = vm.currentBudgetPlan {
                    VStack(spacing: 16) {
                        Text("📊 本月预算规划")
                            .font(.system(.headline, design: .rounded))
                        
                        budgetRow(icon: "house.fill", title: "必要支出 (50%)", amount: plan.needsAmount, color: .blue)
                        budgetRow(icon: "heart.fill", title: "个人想要 (30%)", amount: plan.wantsAmount, color: HKColors.pinkDeep)
                        budgetRow(icon: "banknote.fill", title: "储蓄/还债 (20%)", amount: plan.savingsAmount, color: .green)
                        
                        // 实际支出对比
                        Divider()
                        
                        HStack {
                            Text("本月实际支出")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                            Spacer()
                            Text("¥\(String(format: "%.0f", vm.monthExpense))")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        
                        let remaining = plan.needsAmount - vm.monthExpense
                        HStack {
                            Text(remaining >= 0 ? "剩余预算" : "超出预算")
                                .font(.system(.caption, design: .rounded))
                            Spacer()
                            Text("¥\(String(format: "%.0f", abs(remaining)))")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(remaining >= 0 ? .green : .red)
                        }
                    }
                    .hkPinkCard()
                }
            }
            .padding()
        }
    }
    
    private func budgetRow(icon: String, title: String, amount: Double, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.system(.subheadline, design: .rounded))
            Spacer()
            Text("¥\(String(format: "%.0f", amount))")
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - 欠款管理
struct DebtListView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @State private var showAddDebt = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 汇总
                HStack(spacing: 0) {
                    VStack {
                        Text("\(String(format: "%.0f", vm.totalOweTo))")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("我欠别人")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("\(String(format: "%.0f", vm.totalOwedBy))")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("别人欠我")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .hkPinkCard()
                
                // 欠款列表
                let unpaid = vm.debts.filter { !$0.isPaid }
                let paid = vm.debts.filter { $0.isPaid }
                
                if !unpaid.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ 未还 (\(unpaid.count)条)")
                            .font(.system(.headline, design: .rounded))
                        
                        ForEach(unpaid) { debt in
                            debtRow(debt)
                        }
                    }
                    .hkCard()
                }
                
                if !paid.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✅ 已还 (\(paid.count)条)")
                            .font(.system(.headline, design: .rounded))
                        
                        ForEach(paid) { debt in
                            debtRow(debt)
                        }
                    }
                    .hkCard()
                }
                
                if vm.debts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "creditcard")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("暂无欠款记录")
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddDebt = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddDebt) {
            AddDebtView()
        }
    }
    
    private func debtRow(_ debt: DebtRecord) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(debt.type == .oweTo ? "欠 \(debt.personName)" : "\(debt.personName) 欠我")
                    .font(.system(.body, design: .rounded))
                if !debt.note.isEmpty {
                    Text(debt.note)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("¥\(String(format: "%.0f", debt.amount))")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                Text(debt.date.hkDateString)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .onTapGesture { vm.toggleDebtPaid(debt) }
        .contextMenu {
            Button(role: .destructive) { vm.deleteDebt(debt) } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

// MARK: - 添加欠款
struct AddDebtView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isOweTo = true
    @State private var personName = ""
    @State private var amount = ""
    @State private var note = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("类型") {
                    Picker("", selection: $isOweTo) {
                        Text("我欠别人").tag(true)
                        Text("别人欠我").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                Section("信息") {
                    TextField("对方姓名", text: $personName)
                    TextField("金额", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("备注", text: $note)
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }
                Section {
                    Button(action: addDebt) {
                        HStack {
                            Spacer()
                            Text("添加记录")
                            Spacer()
                        }
                    }
                    .disabled(personName.isEmpty || amount.isEmpty)
                }
            }
            .navigationTitle("添加欠款")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
    
    private func addDebt() {
        guard let amt = Double(amount), !personName.isEmpty else { return }
        vm.addDebt(type: isOweTo ? .oweTo : .owedBy, person: personName, amount: amt, note: note, date: date)
        dismiss()
    }
}

// MARK: - 存钱目标
struct SavingsGoalListView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @State private var showAddGoal = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(vm.savingsGoals) { goal in
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.targetName)
                                    .font(.system(.headline, design: .rounded))
                                Text("目标到期: \(goal.targetDate.hkDateString)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.textSecondary)
                            }
                            Spacer()
                            if goal.isCompleted {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        
                        // 进度条
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(HKColors.pinkLight.opacity(0.3))
                                    .frame(height: 20)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [HKColors.pink, HKColors.pinkDeep]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(goal.progress), height: 20)
                            }
                        }
                        .frame(height: 20)
                        
                        HStack {
                            Text("¥\(String(format: "%.0f", goal.currentAmount)) / ¥\(String(format: "%.0f", goal.targetAmount))")
                                .font(.system(.caption, design: .rounded))
                            Spacer()
                            Text("\(Int(goal.progress * 100))%")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(HKColors.pinkDeep)
                        }
                        
                        if !goal.isCompleted {
                            Button(action: {
                                vm.addSavingsAmount(goal, amount: 100)
                            }) {
                                Label("存入 ¥100", systemImage: "plus.circle.fill")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(HKColors.pinkDeep)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(HKColors.pinkLight.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .hkCard()
                    .contextMenu {
                        Button(role: .destructive) {
                            vm.deleteSavingsGoal(goal)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
                
                if vm.savingsGoals.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "piggy.bank")
                            .font(.largeTitle)
                            .foregroundColor(HKColors.textSecondary)
                        Text("还没有存钱目标")
                            .foregroundColor(HKColors.textSecondary)
                        Text("设定一个目标，开始存钱吧")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddGoal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddSavingsGoalView()
        }
    }
}

struct AddSavingsGoalView: View {
    @EnvironmentObject var vm: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var amount = ""
    @State private var targetDate = Date().addingTimeInterval(90 * 24 * 3600)
    
    var body: some View {
        NavigationView {
            Form {
                TextField("目标名称", text: $name)
                TextField("目标金额", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
                Button("创建目标") {
                    guard let amt = Double(amount), !name.isEmpty else { return }
                    vm.addSavingsGoal(name: name, target: amt, targetDate: targetDate)
                    dismiss()
                }
                .disabled(name.isEmpty || amount.isEmpty)
            }
            .navigationTitle("新增存钱目标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            }
        }
    }
}
