import SwiftUI

/// 主Tab视图 - 5个底部导航Tab
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dietVM = DietViewModel()
    @StateObject private var financeVM = FinanceViewModel()
    @StateObject private var exerciseVM = ExerciseViewModel()
    @StateObject private var weightVM = WeightViewModel()
    @StateObject private var readingVM = ReadingViewModel()
    @StateObject private var studyVM = StudyViewModel()
    @StateObject private var habitVM = HabitViewModel()
    @StateObject private var moodVM = MoodViewModel()
    @StateObject private var overviewVM = OverviewViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 总览
            NavigationView {
                OverviewView(overviewVM: overviewVM, dietVM: dietVM, financeVM: financeVM, exerciseVM: exerciseVM, weightVM: weightVM, habitVM: habitVM, moodVM: moodVM, studyVM: studyVM)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "house.fill")
                Text("总览")
            }
            .tag(0)
            
            // Tab 2: 饮食
            NavigationView {
                DietView()
                    .environmentObject(dietVM)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "fork.knife")
                Text("饮食")
            }
            .tag(1)
            
            // Tab 3: 资金
            NavigationView {
                FinanceView()
                    .environmentObject(financeVM)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "yensign.circle.fill")
                Text("资金")
            }
            .tag(2)
            
            // Tab 4: 健康
            NavigationView {
                HealthView()
                    .environmentObject(exerciseVM)
                    .environmentObject(weightVM)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "heart.fill")
                Text("健康")
            }
            .tag(3)
            
            // Tab 5: 更多
            NavigationView {
                MoreView()
                    .environmentObject(weightVM)
                    .environmentObject(readingVM)
                    .environmentObject(studyVM)
                    .environmentObject(habitVM)
                    .environmentObject(moodVM)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "ellipsis.circle.fill")
                Text("更多")
            }
            .tag(4)
        }
        .accentColor(HKColors.pinkDeep)
        .onAppear {
            // 自定义TabBar外观
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
