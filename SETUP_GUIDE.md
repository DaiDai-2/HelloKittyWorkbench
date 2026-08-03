# Hello Kitty 个人AI工作台 - 搭建指南

## 🚀 快速开始（推荐）

### 方式一：XcodeGen 一键生成（推荐）

在 Mac 上：

```bash
# 1. 安装 XcodeGen（如果还没有）
brew install xcodegen

# 2. 到项目目录
cd HelloKittyWorkbench

# 3. 生成 Xcode 工程
xcodegen generate --spec project.yml

# 4. 打开工程
open HelloKittyWorkbench.xcodeproj

# 5. 按 Cmd+R 编译运行
```

### 方式二：手动在 Xcode 中创建项目

#### 1. 创建 Xcode 项目
1. 打开 **Xcode 14+**
2. 选择 **File → New → Project**
3. 选择 **iOS → App**
4. 填写信息：
   - Product Name: `HelloKittyWorkbench`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 15.0**
5. 保存到本项目目录下

#### 2. 导入源代码文件
将 `HelloKittyWorkbench/` 目录下的所有文件夹拖入 Xcode 项目：
- `App/` - 应用入口
- `Core/` - 核心框架（主题、扩展、服务）
- `Models/` - 数据模型
- `ViewModels/` - 视图模型
- `Views/` - 所有界面视图
- `Resources/` - 资源文件

#### 3. 配置 Xcode 项目
- **Deployment Target**: iOS 15.0
- **Supported Destinations**: iPhone + iPad
- **App Icon**: 添加 1024x1024 Hello Kitty 风格图标
- **Launch Screen**: 粉色背景启动页

#### 4. 删除默认文件
删除 Xcode 自动生成的 `ContentView.swift`，使用本项目中的文件。

## 二、Supabase 配置（可选）

### 1. 创建 Supabase 项目
1. 访问 [supabase.com](https://supabase.com) 注册账号
2. 创建新项目
3. 在 SQL Editor 中创建以下表：

```sql
-- 饮食记录表
CREATE TABLE diet_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  food_name TEXT NOT NULL,
  calories DOUBLE PRECISION,
  portion TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  meal_type TEXT DEFAULT 'snack',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 饮水记录表
CREATE TABLE water_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  amount DOUBLE PRECISION,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 交易记录表
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT,
  amount DOUBLE PRECISION,
  category TEXT,
  note TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 分类表
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 预算计划表
CREATE TABLE budget_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  monthly_salary DOUBLE PRECISION,
  needs_percent DOUBLE PRECISION DEFAULT 50,
  wants_percent DOUBLE PRECISION DEFAULT 30,
  savings_percent DOUBLE PRECISION DEFAULT 20,
  month TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 欠款表
CREATE TABLE debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT,
  person_name TEXT,
  amount DOUBLE PRECISION,
  note TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  is_paid BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 存钱目标表
CREATE TABLE savings_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_name TEXT,
  target_amount DOUBLE PRECISION,
  current_amount DOUBLE PRECISION DEFAULT 0,
  target_date TIMESTAMPTZ,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 运动记录表
CREATE TABLE exercise_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT,
  exercise_name TEXT,
  duration DOUBLE PRECISION,
  calories_burned DOUBLE PRECISION,
  note TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 体重记录表
CREATE TABLE weight_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  weight DOUBLE PRECISION,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 书籍表
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT,
  author TEXT,
  category TEXT,
  recommendation TEXT,
  difficulty TEXT,
  read_status TEXT DEFAULT 'wantToRead',
  current_page INTEGER DEFAULT 0,
  total_page INTEGER DEFAULT 0,
  cover_color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 阅读笔记表
CREATE TABLE reading_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID,
  content TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 阅读内容表
CREATE TABLE reading_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT,
  content TEXT,
  font_size DOUBLE PRECISION DEFAULT 16,
  bg_color TEXT DEFAULT 'white',
  current_page INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 学习目标表
CREATE TABLE study_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_school TEXT,
  target_major TEXT,
  exam_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 考试科目表
CREATE TABLE exam_subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  target_score DOUBLE PRECISION DEFAULT 100,
  current_score DOUBLE PRECISION DEFAULT 0,
  progress DOUBLE PRECISION DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 习惯计划表
CREATE TABLE habit_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  frequency JSONB,
  start_date TIMESTAMPTZ DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  is_paused BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 打卡记录表
CREATE TABLE habit_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID,
  date TIMESTAMPTZ DEFAULT NOW(),
  is_done BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 心情记录表
CREATE TABLE mood_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mood_level TEXT,
  diary TEXT,
  tags TEXT[],
  date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

2. 启用 Row Level Security (RLS) 或暂时关闭
3. 在 App 首次启动时输入 Supabase URL 和 Anon Key

## 三、项目文件结构

```
HelloKittyWorkbench/
├── Package.swift
├── HelloKittyWorkbench/
│   ├── App/
│   │   ├── HelloKittyWorkbenchApp.swift    # App入口
│   │   ├── ContentView.swift               # 根视图
│   │   └── AppState.swift                  # 全局状态
│   ├── Core/
│   │   ├── Theme/
│   │   │   └── HKTheme.swift               # 粉色HelloKitty主题
│   │   ├── Extensions/
│   │   │   └── View+Extensions.swift       # 视图扩展
│   │   └── Services/
│   │       ├── HKFoodDatabase.swift        # 100+食物热量数据
│   │       ├── LocalStorageManager.swift    # 本地存储管理
│   │       ├── SupabaseService.swift        # 云端同步
│   │       ├── DataSyncService.swift        # 同步调度
│   │       └── NotificationService.swift    # 本地通知
│   ├── Models/
│   │   ├── Models.swift                    # 所有数据模型
│   │   └── CoreDataStack.swift             # Core Data管理
│   ├── ViewModels/
│   │   ├── DietViewModel.swift             # 饮食管理
│   │   ├── FinanceViewModel.swift          # 资金管理
│   │   ├── ExerciseViewModel.swift         # 健康运动
│   │   ├── WeightViewModel.swift           # 体重记录
│   │   ├── ReadingViewModel.swift          # 读书管理
│   │   ├── StudyViewModel.swift            # 学习目标
│   │   ├── HabitViewModel.swift            # 计划打卡
│   │   ├── MoodViewModel.swift             # 心情日记
│   │   └── OverviewViewModel.swift         # 总览
│   └── Views/
│       ├── MainTabView.swift               # 5个底部Tab
│       ├── Overview/OverviewView.swift     # 总览首页
│       ├── Diet/DietView.swift             # 饮食管理
│       ├── Finance/FinanceView.swift       # 资金管理
│       ├── Health/HealthView.swift         # 健康运动+体重
│       ├── More/
│       │   ├── MoreView.swift              # 更多入口
│       │   ├── StudyGoalView.swift         # 学习目标
│       │   ├── HabitTrackView.swift        # 计划打卡
│       │   └── MoodTrackView.swift         # 心情日记
│       └── Settings/SettingsView.swift     # 设置页
└── Resources/
    └── Info.plist
```

## 四、功能清单

| 模块 | Tab | 功能 |
|------|-----|------|
| 🏠 总览 | Tab1 | 个人卡片、今日摘要、快捷入口、每日一句 |
| 🍽️ 饮食 | Tab2 | 热量查询、今日记录、饮水记录 |
| 💰 资金 | Tab3 | 收支记录、预算规划、欠款管理、存钱目标 |
| 🏋️ 健康 | Tab4 | 运动打卡、体重记录 |
| 📚 读书 | Tab5 | 书单推荐、阅读记录、在线阅读、阅读笔记 |
| 📖 学习目标 | Tab5 | 倒计时、科目管理、进度追踪(可删除) |
| 📋 计划打卡 | Tab5 | 每日打卡、热力图、连续统计 |
| 😊 心情 | Tab5 | 心情记录、心情日历、日记回顾 |

## 五、编译运行

1. 用 Xcode 14+ 打开项目
2. 选择目标设备 (iPhone/iPad Simulator 或真机)
3. 按 `Cmd+R` 编译运行
4. 首次启动会提示配置 Supabase（可选择跳过）

## 六、注意事项

- 饮食记录不可清零/批量删除
- 单条记录可删除，不可一键清空
- 学习模块支持整体删除
- 数据自动保存，无需手动保存
- 支持 JSON 导出/导入备份
