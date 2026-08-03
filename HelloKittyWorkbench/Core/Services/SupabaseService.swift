import Foundation
import Combine

/// Supabase云端同步服务
class SupabaseService {
    static let shared = SupabaseService()
    
    private var baseURL: String = ""
    private var anonKey: String = ""
    private var isConfigured = false
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    func configure(url: String, key: String) {
        self.baseURL = url.hasSuffix("/") ? String(url.dropLast()) : url
        self.anonKey = key
        self.isConfigured = true
    }
    
    var connected: Bool { isConfigured }
    
    // MARK: - 通用CRUD操作
    
    /// 获取所有记录
    func fetch<T: Codable>(table: String) async throws -> [T] {
        guard isConfigured else { throw SyncError.notConfigured }
        guard let url = URL(string: "\(baseURL)/rest/v1/\(table)?select=*") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([T].self, from: data)
    }
    
    /// 插入记录
    func insert<T: Codable>(_ item: T, table: String) async throws {
        guard isConfigured else { return }
        guard let url = URL(string: "\(baseURL)/rest/v1/\(table)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(item)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }
    
    /// 批量插入
    func insertBatch<T: Codable>(_ items: [T], table: String) async throws {
        guard isConfigured, !items.isEmpty else { return }
        guard let url = URL(string: "\(baseURL)/rest/v1/\(table)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(items)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }
    
    /// 更新记录
    func update<T: Codable & Identifiable>(_ item: T, table: String, idKey: String = "id") async throws where T.ID == UUID {
        guard isConfigured else { return }
        guard let url = URL(string: "\(baseURL)/rest/v1/\(table)?\(idKey)=eq.\(item.id.uuidString)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(item)
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }
    
    /// 删除记录
    func delete(id: UUID, table: String, idKey: String = "id") async throws {
        guard isConfigured else { return }
        guard let url = URL(string: "\(baseURL)/rest/v1/\(table)?\(idKey)=eq.\(id.uuidString)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }
}

enum SyncError: Error {
    case notConfigured
    case invalidURL
    case serverError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .notConfigured: return "Supabase未配置"
        case .invalidURL: return "无效的URL"
        case .serverError: return "服务器错误"
        case .networkError: return "网络连接失败"
        }
    }
}
