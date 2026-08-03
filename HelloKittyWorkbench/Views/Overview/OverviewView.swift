import SwiftUI

/// 总览页面
struct OverviewView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var overviewVM: OverviewViewModel
    @ObservedObject var dietVM: DietViewModel
    @ObservedObject var financeVM: FinanceViewModel
    @ObservedObject var exerciseVM: ExerciseViewModel
    @ObservedObject var weightVM: WeightViewModel
    @ObservedObject var habitVM: HabitViewModel
    @ObservedObject var moodVM: MoodViewModel
    @ObservedObject var studyVM: StudyViewModel
    
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 同步状态
                syncStatusBar
                
                // 个人卡片
                personalCard
                
                // 每日一句
                dailyQuoteCard
                
                // 今日数据摘要
                todaySummaryGrid
                
                // 快捷入口
                quickAccessGrid
            }
            .padding()
        }
        .background(HKColors.bgLight.ignoresSafeArea())
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(HKColors.pinkDeep)
                    Text("Hello Kitty 工作台")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - 同步状态栏
    private var syncStatusBar: some View {
        HStack {
            Spacer()
            Image(systemName: appState.syncStatus.icon)
                .foregroundColor(appState.syncStatus.color)
            Text(appState.syncStatus.label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(appState.syncStatus.color)
            Spacer()
        }
        .padding(.vertical, 6)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(10)
    }
    
    // MARK: - 个人卡片
    private var personalCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // 头像
                ZStack {
                    Circle()
                        .fill(HKColors.pinkLight)
                        .frame(width: 70, height: 70)
                    
                    if let avatarData = overviewVM.userProfile.avatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 66, height: 66)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(HKColors.pinkDeep)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(overviewVM.userProfile.nickname)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.textPrimary)
                    
                    Text(Date().hkWeekdayString + "好呀~")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(HKColors.pink)
            }
        }
        .hkPinkCard()
    }
    
    // MARK: - 每日一句
    private var dailyQuoteCard: some View {
        HStack(spacing: 8) {
            Text("✨")
                .font(.title3)
            Text(appState.dailyQuote)
                .font(.system(.body, design: .rounded))
                .foregroundColor(HKColors.textPrimary)
                .lineLimit(2)
            Spacer()
            Button(action: { appState.refreshDailyQuote() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(HKColors.pink)
            }
        }
        .hkCard()
    }
    
    // MARK: - 今日数据摘要
    private var todaySummaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryItem(icon: "flame.fill", color: .orange, title: "今日摄入", value: "\(Int(dietVM.todayTotalCalories)) kcal")
            summaryItem(icon: "drop.fill", color: .blue, title: "饮水进度", value: "\(Int(dietVM.waterProgress * 100))%")
            summaryItem(icon: "yensign.circle.fill", color: .green, title: "今日支出", value: "¥\(String(format: "%.0f", financeVM.todayExpense))")
            summaryItem(icon: "figure.run", color: HKColors.pinkDeep, title: "运动", value: exerciseVM.todayExercised ? "✅ 已打卡" : "⏳ 未运动")
            
            if let weight = weightVM.latestWeight, let bmi = weightVM.bmi {
                summaryItem(icon: "scalemass.fill", color: .purple, title: "体重/BMI", value: "\(String(format: "%.1f", weight))/\(String(format: "%.1f", bmi))")
            }
            
            if let todayMood = moodVM.todayMood {
                summaryItem(icon: "face.smiling.fill", color: HKColors.pink, title: "今日心情", value: todayMood.moodLevel.rawValue)
            }
            
            summaryItem(icon: "checkmark.seal.fill", color: .teal, title: "计划进度", value: "\(habitVM.todayDoneCount)/\(habitVM.todayPlans.count)")
        }
    }
    
    private func summaryItem(icon: String, color: Color, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HKColors.textSecondary)
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(HKColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 快捷入口
    private var quickAccessGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HKSectionHeader(title: "快捷入口", icon: "rectangle.grid.2x2.fill")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickAccessCard(icon: "fork.knife", title: "饮食", color: HKColors.tab2, tab: 1)
                quickAccessCard(icon: "yensign.circle.fill", title: "资金", color: HKColors.tab3, tab: 2)
                quickAccessCard(icon: "heart.fill", title: "健康", color: HKColors.tab4, tab: 3)
                quickAccessCard(icon: "book.fill", title: "读书", color: .cyan)
                quickAccessCard(icon: "pencil.and.list.clipboard", title: "计划", color: .orange)
                quickAccessCard(icon: "face.smiling.fill", title: "心情", color: HKColors.pink)
            }
        }
    }
    
    private func quickAccessCard(icon: String, title: String, color: Color, tab: Int? = nil) -> some View {
        Button(action: {
            // 通过改变selectedTab跳转（需要通知MainTabView）
            hkHaptic(.light)
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }
}
