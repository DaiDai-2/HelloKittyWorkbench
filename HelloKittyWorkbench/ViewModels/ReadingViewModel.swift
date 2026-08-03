import Foundation

/// 读书管理 ViewModel
class ReadingViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var readingNotes: [ReadingNote] = []
    @Published var readingContents: [ReadingContent] = []
    @Published var selectedCategory: String? = nil
    
    private let storage = LocalStorageManager.shared
    
    let categories = ["个人成长", "心理学", "职场", "理财", "健康", "文学", "哲学", "科技"]
    
    init() {
        loadData()
        if books.isEmpty {
            setupDefaultBooks()
        }
    }
    
    func loadData() {
        books = storage.loadBooks()
        readingNotes = storage.loadReadingNotes()
        readingContents = storage.loadReadingContents()
    }
    
    private func setupDefaultBooks() {
        books = [
            Book(title: "原子习惯", author: "James Clear", category: "个人成长", recommendation: "微小改变带来巨大成果，适合想养成好习惯的你", difficulty: .beginner, coverColor: "#FFB6C1"),
            Book(title: "被讨厌的勇气", author: "岸见一郎/古贺史健", category: "心理学", recommendation: "阿德勒心理学入门，帮你获得真正的自由和幸福", difficulty: .beginner, coverColor: "#FFC0CB"),
            Book(title: "非暴力沟通", author: "马歇尔·卢森堡", category: "个人成长", recommendation: "改善人际关系和沟通方式的实用指南", difficulty: .beginner, coverColor: "#FFD1DC"),
            Book(title: "思考快与慢", author: "丹尼尔·卡尼曼", category: "心理学", recommendation: "理解人类思维的两套系统，提升决策能力", difficulty: .advanced, coverColor: "#FF69B4"),
            Book(title: "穷查理宝典", author: "查理·芒格", category: "理财", recommendation: "投资智慧和人生哲学的经典合集", difficulty: .intermediate, coverColor: "#FF85A2"),
            Book(title: "原则", author: "Ray Dalio", category: "职场", recommendation: "桥水基金创始人的生活和工作原则", difficulty: .intermediate, coverColor: "#FF1493"),
            Book(title: "刻意练习", author: "安德斯·艾利克森", category: "个人成长", recommendation: "如何通过科学的练习方法成为专家", difficulty: .beginner, coverColor: "#FFB6C1"),
            Book(title: "影响力", author: "罗伯特·西奥迪尼", category: "心理学", recommendation: "理解说服力的六大原则，做更聪明的决策者", difficulty: .intermediate, coverColor: "#FFC0CB"),
            Book(title: "人性的弱点", author: "戴尔·卡耐基", category: "个人成长", recommendation: "人际关系经典著作，永不过时的社交智慧", difficulty: .beginner, coverColor: "#FFD1DC"),
            Book(title: "高效能人士的七个习惯", author: "史蒂芬·柯维", category: "职场", recommendation: "全面提升个人效能的经典方法论", difficulty: .intermediate, coverColor: "#FF69B4"),
            Book(title: "金字塔原理", author: "芭芭拉·明托", category: "职场", recommendation: "麦肯锡经典写作和思考方法", difficulty: .intermediate, coverColor: "#FF85A2"),
            Book(title: "我们为什么要睡觉", author: "马修·沃克", category: "健康", recommendation: "科学认识睡眠，改善你的睡眠质量", difficulty: .beginner, coverColor: "#FFB6C1"),
            Book(title: "人类简史", author: "尤瓦尔·赫拉利", category: "文学", recommendation: "从认知革命到人工智能的人类文明历程", difficulty: .intermediate, coverColor: "#FFC0CB"),
            Book(title: "也许你该找个人聊聊", author: "洛莉·戈特利布", category: "心理学", recommendation: "一位心理治疗师的治疗故事，温暖治愈", difficulty: .beginner, coverColor: "#FFD1DC"),
            Book(title: "认知觉醒", author: "周岭", category: "个人成长", recommendation: "开启自我改变的原动力，适合每个想成长的人", difficulty: .beginner, coverColor: "#FF69B4"),
            Book(title: "纳瓦尔宝典", author: "Eric Jorgenson", category: "理财", recommendation: "关于财富积累和幸福人生的智慧箴言", difficulty: .beginner, coverColor: "#FF85A2"),
            Book(title: "关键对话", author: "科里·帕特森", category: "职场", recommendation: "掌握高风险对话的技巧，提升沟通力", difficulty: .intermediate, coverColor: "#FF1493"),
            Book(title: "自控力", author: "凯利·麦格尼格尔", category: "心理学", recommendation: "斯坦福大学广受欢迎的意志力课程", difficulty: .beginner, coverColor: "#FFB6C1"),
            Book(title: "心流", author: "米哈里·契克森米哈赖", category: "心理学", recommendation: "最优体验心理学，找到沉浸投入的快乐", difficulty: .intermediate, coverColor: "#FFC0CB"),
            Book(title: "活出生命的意义", author: "维克多·弗兰克尔", category: "哲学", recommendation: "在极端环境下寻找意义的经典之作", difficulty: .advanced, coverColor: "#FFD1DC"),
            Book(title: "终身成长", author: "卡罗尔·德韦克", category: "个人成长", recommendation: "固定思维vs成长思维，改变你的思维模式", difficulty: .beginner, coverColor: "#FF69B4"),
            Book(title: "反脆弱", author: "纳西姆·塔勒布", category: "哲学", recommendation: "从不确定性中获益的哲学思考", difficulty: .advanced, coverColor: "#FF85A2"),
            Book(title: "小王子", author: "安托万·德·圣-埃克苏佩里", category: "文学", recommendation: "用童心看世界的经典文学，百读不厌", difficulty: .beginner, coverColor: "#FFB6C1"),
            Book(title: "禅与摩托车维修艺术", author: "罗伯特·波西格", category: "哲学", recommendation: "一趟关于质量和价值的哲学之旅", difficulty: .advanced, coverColor: "#FFC0CB"),
            Book(title: "深度工作", author: "卡尔·纽波特", category: "职场", recommendation: "在碎片化时代重获专注力的方法", difficulty: .beginner, coverColor: "#FF1493")
        ]
        saveBooks()
    }
    
    // MARK: - 书籍管理
    var filteredBooks: [Book] {
        if let category = selectedCategory {
            return books.filter { $0.category == category }
        }
        return books
    }
    
    func updateBookStatus(_ book: Book, status: Book.ReadStatus) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].readStatus = status
            saveBooks()
        }
    }
    
    func updateReadingProgress(_ book: Book, currentPage: Int) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].currentPage = currentPage
            saveBooks()
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    // MARK: - 阅读笔记
    func addNote(bookId: UUID, content: String) {
        let note = ReadingNote(bookId: bookId, content: content, date: Date())
        readingNotes.append(note)
        saveNotes()
        hkHaptic(.medium)
    }
    
    func deleteNote(_ note: ReadingNote) {
        readingNotes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    func notesFor(bookId: UUID) -> [ReadingNote] {
        readingNotes.filter { $0.bookId == bookId }.sorted { $0.date > $1.date }
    }
    
    func searchNotes(keyword: String) -> [ReadingNote] {
        guard !keyword.isEmpty else { return [] }
        return readingNotes.filter { $0.content.localizedCaseInsensitiveContains(keyword) }
    }
    
    // MARK: - 阅读内容
    func addReadingContent(_ content: ReadingContent) {
        readingContents.append(content)
        saveContents()
    }
    
    func updateReadingContent(_ content: ReadingContent) {
        if let index = readingContents.firstIndex(where: { $0.id == content.id }) {
            readingContents[index] = content
            saveContents()
        }
    }
    
    func deleteReadingContent(_ content: ReadingContent) {
        readingContents.removeAll { $0.id == content.id }
        saveContents()
    }
    
    private func saveBooks() { storage.saveBooks(books) }
    private func saveNotes() { storage.saveReadingNotes(readingNotes) }
    private func saveContents() { storage.saveReadingContents(readingContents) }
}
