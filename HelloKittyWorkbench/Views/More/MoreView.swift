import SwiftUI

/// 更多模块入口
struct MoreView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var weightVM: WeightViewModel
    @EnvironmentObject var readingVM: ReadingViewModel
    @EnvironmentObject var studyVM: StudyViewModel
    @EnvironmentObject var habitVM: HabitViewModel
    @EnvironmentObject var moodVM: MoodViewModel
    
    var body: some View {
        List {
            // 体重
            NavigationLink(destination: WeightTrackView()) {
                Label {
                    Text("⚖️ 体重记录")
                } icon: {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(.purple)
                }
            }
            
            // 读书
            NavigationLink(destination: ReadingListView()) {
                Label {
                    Text("📚 读书")
                } icon: {
                    Image(systemName: "book.fill")
                        .foregroundColor(.cyan)
                }
            }
            
            // 学习（可删除模块）
            if !appState.studyModuleDeleted {
                NavigationLink(destination: StudyGoalView()) {
                    Label {
                        Text("📖 学习目标")
                    } icon: {
                        Image(systemName: "graduationcap.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // 计划打卡
            NavigationLink(destination: HabitTrackView()) {
                Label {
                    Text("📋 计划打卡")
                } icon: {
                    Image(systemName: "checklist")
                        .foregroundColor(.teal)
                }
            }
            
            // 心情
            NavigationLink(destination: MoodTrackView()) {
                Label {
                    Text("😊 心情日记")
                } icon: {
                    Image(systemName: "face.smiling.fill")
                        .foregroundColor(HKColors.pink)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("更多")
        .background(HKColors.bgLight)
    }
}

// MARK: - 读书列表
struct ReadingListView: View {
    @EnvironmentObject var vm: ReadingViewModel
    @State private var showReader = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 分类筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip("全部", isSelected: vm.selectedCategory == nil) {
                        vm.selectedCategory = nil
                    }
                    ForEach(vm.categories, id: \.self) { cat in
                        categoryChip(cat, isSelected: vm.selectedCategory == cat) {
                            vm.selectedCategory = cat
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            List {
                ForEach(vm.filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookRowView(book: book)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("📚 读书")
        .background(HKColors.bgLight)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ReadingContentView()) {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
    }
    
    private func categoryChip(_ text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(isSelected ? .white : HKColors.pinkDeep)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? HKColors.pinkDeep : HKColors.pinkLight.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            // 封面占位
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: book.coverColor))
                .frame(width: 50, height: 70)
                .overlay(
                    Text(String(book.title.prefix(2)))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                Text(book.author)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HKColors.textSecondary)
                
                HStack(spacing: 6) {
                    Text(book.category)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(HKColors.pinkDeep)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(HKColors.pinkLight.opacity(0.3))
                        .cornerRadius(4)
                    
                    Text(book.difficulty.rawValue)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // 状态标签
            statusBadge(book.readStatus)
        }
        .padding(.vertical, 4)
    }
    
    private func statusBadge(_ status: Book.ReadStatus) -> some View {
        Text(status.rawValue)
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor(status).opacity(0.15))
            .cornerRadius(6)
    }
    
    private func statusColor(_ status: Book.ReadStatus) -> Color {
        switch status {
        case .wantToRead: return .blue
        case .reading: return .orange
        case .finished: return .green
        }
    }
}

// MARK: - 读书详情
struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var vm: ReadingViewModel
    @State private var showAddNote = false
    @State private var noteContent = ""
    @State private var localBook: Book
    
    init(book: Book) {
        self.book = book
        _localBook = State(initialValue: book)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 书籍信息
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: localBook.coverColor))
                        .frame(height: 160)
                        .overlay(
                            Text(localBook.title)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    Text(localBook.author)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(HKColors.textSecondary)
                    
                    Text(localBook.recommendation)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(HKColors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .hkPinkCard()
                
                // 阅读状态
                VStack(spacing: 12) {
                    Picker("状态", selection: Binding(
                        get: { localBook.readStatus },
                        set: { newStatus in
                            localBook.readStatus = newStatus
                            vm.updateBookStatus(localBook, status: newStatus)
                        }
                    )) {
                        ForEach(Book.ReadStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if localBook.readStatus == .reading {
                        VStack(spacing: 8) {
                            HStack {
                                Text("阅读进度")
                                Spacer()
                                Text("\(localBook.currentPage)/\(localBook.totalPage) 页")
                                    .font(.system(.caption, design: .rounded))
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(HKColors.pinkLight.opacity(0.3))
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(HKColors.pinkDeep)
                                        .frame(width: geo.size.width * CGFloat(localBook.progress), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            HStack {
                                TextField("总页数", value: $localBook.totalPage, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                TextField("当前页", value: $localBook.currentPage, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                Button("更新") {
                                    vm.updateReadingProgress(localBook, currentPage: localBook.currentPage)
                                }
                                .font(.system(.caption, design: .rounded))
                                .hkPrimaryButton()
                            }
                        }
                    }
                }
                .hkCard()
                
                // 阅读笔记
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("📝 阅读笔记")
                            .font(.system(.headline, design: .rounded))
                        Spacer()
                        Button(action: { showAddNote = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(HKColors.pinkDeep)
                        }
                    }
                    
                    let notes = vm.notesFor(bookId: localBook.id)
                    if notes.isEmpty {
                        Text("还没有笔记")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                    
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.content)
                                .font(.system(.body, design: .rounded))
                            Text(note.date.hkFullString)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(HKColors.textSecondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteNote(note)
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
        .background(HKColors.bgLight)
        .navigationTitle(localBook.title)
        .sheet(isPresented: $showAddNote) {
            NavigationView {
                VStack(spacing: 16) {
                    Text("添加阅读笔记")
                        .font(.system(.headline, design: .rounded))
                    
                    TextEditor(text: $noteContent)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button("保存笔记") {
                        guard !noteContent.isEmpty else { return }
                        vm.addNote(bookId: localBook.id, content: noteContent)
                        noteContent = ""
                        showAddNote = false
                    }
                    .hkPrimaryButton()
                    .disabled(noteContent.isEmpty)
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { showAddNote = false }
                    }
                }
            }
        }
    }
}

// MARK: - 在线阅读区
struct ReadingContentView: View {
    @EnvironmentObject var vm: ReadingViewModel
    @State private var showAddContent = false
    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var selectedFontSize: Double = 16
    @State private var selectedBg = "white"
    
    var body: some View {
        List {
            ForEach(vm.readingContents) { content in
                NavigationLink(destination: ReaderView(content: content)) {
                    VStack(alignment: .leading) {
                        Text(content.title)
                            .font(.system(.body, design: .rounded))
                        Text(content.createdAt.hkDateString)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(HKColors.textSecondary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    vm.deleteReadingContent(vm.readingContents[index])
                }
            }
        }
        .navigationTitle("在线阅读")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddContent = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(HKColors.pinkDeep)
                }
            }
        }
        .sheet(isPresented: $showAddContent) {
            NavigationView {
                Form {
                    TextField("标题", text: $newTitle)
                    Section("内容") {
                        TextEditor(text: $newContent)
                            .frame(minHeight: 200)
                    }
                    Button("保存") {
                        guard !newTitle.isEmpty else { return }
                        vm.addReadingContent(ReadingContent(title: newTitle, content: newContent))
                        newTitle = ""
                        newContent = ""
                        showAddContent = false
                    }
                    .disabled(newTitle.isEmpty)
                }
                .navigationTitle("添加内容")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { showAddContent = false } }
                }
            }
        }
    }
}

struct ReaderView: View {
    let content: ReadingContent
    @State private var fontSize: Double
    @State private var bgColor: String
    
    init(content: ReadingContent) {
        self.content = content
        _fontSize = State(initialValue: content.fontSize)
        _bgColor = State(initialValue: content.bgColor)
    }
    
    var bg: Color {
        switch bgColor {
        case "cream": return Color(hex: "#FFFDD0") // 羊皮纸
        case "green": return Color(hex: "#C8DCC8") // 护眼
        default: return .white
        }
    }
    
    var body: some View {
        ScrollView {
            Text(content.content)
                .font(.system(size: fontSize, design: .serif))
                .padding()
                .background(bg)
                .cornerRadius(12)
        }
        .background(bg)
        .navigationTitle(content.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("白色背景") { bgColor = "white" }
                    Button("羊皮纸") { bgColor = "cream" }
                    Button("护眼模式") { bgColor = "green" }
                    
                    Divider()
                    
                    ForEach([14.0, 16.0, 18.0, 20.0, 24.0], id: \.self) { size in
                        Button("字号 \(Int(size))") { fontSize = size }
                    }
                } label: {
                    Image(systemName: "textformat.size")
                }
            }
        }
    }
}
