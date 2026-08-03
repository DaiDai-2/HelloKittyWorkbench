import SwiftUI

/// 根视图 - 判断是否已配置Supabase
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.supabaseConfigured {
            MainTabView()
        } else {
            WelcomeSetupView()
        }
    }
}

/// 首次安装引导页
struct WelcomeSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var supabaseURL: String = ""
    @State private var supabaseKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [HKColors.pinkLight, HKColors.bgLight, HKColors.pink.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Hello Kitty 装饰
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(HKColors.pinkLight.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(HKColors.pinkDeep)
                    }
                    
                    Text("Hello Kitty 工作台")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(HKColors.pinkDeep)
                    
                    Text("你的AI个人工作台 🎀")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                }
                
                // 配置表单
                VStack(spacing: 16) {
                    Text("设置云端同步")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(HKColors.textPrimary)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(HKColors.pinkDeep)
                            TextField("Supabase URL", text: $supabaseURL)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .font(.system(.body, design: .rounded))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(HKColors.pinkDeep)
                            SecureField("Supabase Anon Key", text: $supabaseKey)
                                .font(.system(.body, design: .rounded))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: setupSupabase) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up.fill")
                            Text("连接云端")
                        }
                        .hkPrimaryButton()
                    }
                    
                    Button(action: skipSetup) {
                        Text("先跳过，本地使用")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                }
                .hkCard()
                .padding(.horizontal, 24)
                
                Spacer()
                
                Text("数据将加密同步至你的Supabase云端")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
                    .padding(.bottom, 40)
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func setupSupabase() {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            alertMessage = "请填写完整的Supabase连接信息"
            showAlert = true
            return
        }
        
        SupabaseService.shared.configure(url: supabaseURL, key: supabaseKey)
        appState.supabaseConfigured = true
        appState.syncStatus = .connected
    }
    
    private func skipSetup() {
        appState.supabaseConfigured = true
        appState.syncStatus = .disconnected
    }
}
