import Foundation

/// 学习目标 ViewModel（支持整体删除）
class StudyViewModel: ObservableObject {
    @Published var studyGoal: StudyGoal?
    @Published var subjects: [ExamSubject] = []
    
    private let storage = LocalStorageManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        studyGoal = storage.loadStudyGoal()
        subjects = storage.loadExamSubjects()
    }
    
    // MARK: - 学习目标
    func setStudyGoal(school: String, major: String, examDate: Date) {
        studyGoal = StudyGoal(targetSchool: school, targetMajor: major, examDate: examDate)
        saveGoal()
    }
    
    var daysRemaining: Int {
        studyGoal?.daysRemaining ?? 0
    }
    
    // MARK: - 科目管理
    func addSubject(name: String, targetScore: Double = 100) {
        let subject = ExamSubject(name: name, targetScore: targetScore)
        subjects.append(subject)
        saveSubjects()
    }
    
    func updateSubjectProgress(_ subject: ExamSubject, progress: Double, currentScore: Double) {
        if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
            subjects[index].progress = min(progress, 1.0)
            subjects[index].currentScore = currentScore
            saveSubjects()
        }
    }
    
    func deleteSubject(_ subject: ExamSubject) {
        subjects.removeAll { $0.id == subject.id }
        saveSubjects()
    }
    
    /// 总体进度
    var overallProgress: Double {
        guard !subjects.isEmpty else { return 0 }
        return subjects.reduce(0) { $0 + $1.progress } / Double(subjects.count)
    }
    
    /// 删除整个学习模块
    func deleteModule() {
        studyGoal = nil
        subjects.removeAll()
        // 清除本地存储
        storage.deleteFile("study_goal")
        storage.deleteFile("exam_subjects")
        
        AppState.shared.studyModuleDeleted = true
    }
    
    private func saveGoal() {
        if let goal = studyGoal {
            storage.saveStudyGoal(goal)
        }
    }
    
    private func saveSubjects() {
        storage.saveExamSubjects(subjects)
    }
}
