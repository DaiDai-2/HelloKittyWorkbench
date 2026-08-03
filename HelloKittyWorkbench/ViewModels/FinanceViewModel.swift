import Foundation
import Combine

/// 资金管理 ViewModel
class FinanceViewModel: ObservableObject {
    @Published var transactions: [TransactionRecord] = []
    @Published var incomeCategories: [CategoryItem] = []
    @Published var expenseCategories: [CategoryItem] = []
    @Published var budgetPlans: [BudgetPlan] = []
    @Published var debts: [DebtRecord] = []
    @Published var savingsGoals: [SavingsGoal] = []
    
    private let storage = LocalStorageManager.shared
    
    init() {
        loadData()
        if incomeCategories.isEmpty && expenseCategories.isEmpty {
            setupDefaultCategories()
        }
    }
    
    func loadData() {
        transactions = storage.loadTransactions()
        incomeCategories = storage.loadCategories().filter { $0.type == "income" }
        expenseCategories = storage.loadCategories().filter { $0.type == "expense" }
        budgetPlans = storage.loadBudgetPlans()
        debts = storage.loadDebts()
        savingsGoals = storage.loadSavingsGoals()
    }
    
    private func setupDefaultCategories() {
        incomeCategories = [
            CategoryItem(name: "工资", type: "income"),
            CategoryItem(name: "兼职", type: "income"),
            CategoryItem(name: "奖金", type: "income"),
            CategoryItem(name: "其他", type: "income")
        ]
        expenseCategories = [
            CategoryItem(name: "餐饮", type: "expense"),
            CategoryItem(name: "交通", type: "expense"),
            CategoryItem(name: "购物", type: "expense"),
            CategoryItem(name: "住房", type: "expense"),
            CategoryItem(name: "娱乐", type: "expense"),
            CategoryItem(name: "学习", type: "expense"),
            CategoryItem(name: "医疗", type: "expense"),
            CategoryItem(name: "其他", type: "expense")
        ]
        saveCategories()
    }
    
    // MARK: - 收支记录
    func addTransaction(type: TransactionRecord.TransactionType, amount: Double, category: String, note: String, date: Date = Date()) {
        let record = TransactionRecord(type: type, amount: amount, category: category, note: note, date: date)
        transactions.append(record)
        saveTransactions()
        hkHaptic(.medium)
    }
    
    func deleteTransaction(_ record: TransactionRecord) {
        transactions.removeAll { $0.id == record.id }
        saveTransactions()
    }
    
    /// 今日收入
    var todayIncome: Double {
        let today = Date().startOfDay
        return transactions
            .filter { $0.date.startOfDay == today && $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// 今日支出
    var todayExpense: Double {
        let today = Date().startOfDay
        return transactions
            .filter { $0.date.startOfDay == today && $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// 本月收入
    var monthIncome: Double {
        let startOfMonth = Date().startOfMonth
        return transactions
            .filter { $0.date >= startOfMonth && $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// 本月支出
    var monthExpense: Double {
        let startOfMonth = Date().startOfMonth
        return transactions
            .filter { $0.date >= startOfMonth && $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// 支出分类汇总
    var expenseByCategory: [(category: String, amount: Double)] {
        let startOfMonth = Date().startOfMonth
        let monthExpenses = transactions.filter { $0.date >= startOfMonth && $0.type == .expense }
        let grouped = Dictionary(grouping: monthExpenses, by: { $0.category })
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
    
    /// 收入分类汇总
    var incomeByCategory: [(category: String, amount: Double)] {
        let startOfMonth = Date().startOfMonth
        let monthIncomes = transactions.filter { $0.date >= startOfMonth && $0.type == .income }
        let grouped = Dictionary(grouping: monthIncomes, by: { $0.category })
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
    
    // MARK: - 分类管理
    func addCategory(name: String, type: String) {
        let category = CategoryItem(name: name, type: type)
        if type == "income" {
            incomeCategories.append(category)
        } else {
            expenseCategories.append(category)
        }
        saveCategories()
    }
    
    func deleteCategory(_ category: CategoryItem) {
        incomeCategories.removeAll { $0.id == category.id }
        expenseCategories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    private func saveCategories() {
        let all = incomeCategories + expenseCategories
        storage.saveCategories(all)
    }
    
    // MARK: - 支出规划
    func setBudgetPlan(salary: Double, needs: Double = 50, wants: Double = 30, savings: Double = 20) {
        let plan = BudgetPlan(
            monthlySalary: salary,
            needsPercent: needs,
            wantsPercent: wants,
            savingsPercent: savings,
            month: Date().startOfMonth
        )
        if let index = budgetPlans.firstIndex(where: { $0.month.startOfMonth == plan.month.startOfMonth }) {
            budgetPlans[index] = plan
        } else {
            budgetPlans.append(plan)
        }
        saveBudgetPlans()
    }
    
    var currentBudgetPlan: BudgetPlan? {
        budgetPlans.first { $0.month.startOfMonth == Date().startOfMonth }
    }
    
    private func saveBudgetPlans() {
        storage.saveBudgetPlans(budgetPlans)
    }
    
    // MARK: - 欠款管理
    func addDebt(type: DebtRecord.DebtType, person: String, amount: Double, note: String, date: Date = Date()) {
        let debt = DebtRecord(type: type, personName: person, amount: amount, note: note, date: date)
        debts.append(debt)
        saveDebts()
        hkHaptic(.medium)
    }
    
    func toggleDebtPaid(_ debt: DebtRecord) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].isPaid.toggle()
            saveDebts()
        }
    }
    
    func deleteDebt(_ debt: DebtRecord) {
        debts.removeAll { $0.id == debt.id }
        saveDebts()
    }
    
    /// 我欠别人的总额
    var totalOweTo: Double {
        debts.filter { $0.type == .oweTo && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    /// 别人欠我的总额
    var totalOwedBy: Double {
        debts.filter { $0.type == .owedBy && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    private func saveDebts() {
        storage.saveDebts(debts)
    }
    
    // MARK: - 存钱目标
    func addSavingsGoal(name: String, target: Double, targetDate: Date) {
        let goal = SavingsGoal(targetName: name, targetAmount: target, targetDate: targetDate)
        savingsGoals.append(goal)
        saveSavingsGoals()
        hkHaptic(.medium)
    }
    
    func addSavingsAmount(_ goal: SavingsGoal, amount: Double) {
        if let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) {
            savingsGoals[index].currentAmount += amount
            if savingsGoals[index].currentAmount >= savingsGoals[index].targetAmount {
                savingsGoals[index].isCompleted = true
            }
            saveSavingsGoals()
            hkHaptic(.light)
        }
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll { $0.id == goal.id }
        saveSavingsGoals()
    }
    
    private func saveSavingsGoals() {
        storage.saveSavingsGoals(savingsGoals)
    }
    
    // MARK: - 同步
    private func saveTransactions() {
        storage.saveTransactions(transactions)
        DataSyncService.shared.markNeedsSync(table: "transactions")
        updateOverview()
    }
    
    private func updateOverview() {
        DispatchQueue.main.async {
            AppState.shared.todayIncome = self.todayIncome
            AppState.shared.todayExpense = self.todayExpense
        }
    }
}
