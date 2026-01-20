//
//  NetworkService.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 19.01.2026.
//

import SwiftUI
import Foundation

// MARK: - App Token
struct AppToken {
    static var bearerToken: String = "" {
        didSet {
            #if DEBUG
            print("🔑 Token updated: \(bearerToken.isEmpty ? "EMPTY" : "SET")")
            #endif
        }
    }
}

// MARK: - Multipart Form Data
struct MultipartFormData {
    struct Part {
        let name: String
        let filename: String?
        let mimeType: String?
        let data: Data
    }

    var parts: [Part] = []

    mutating func addField(_ name: String, _ value: String) {
        parts.append(.init(name: name, filename: nil, mimeType: nil, data: Data(value.utf8)))
    }

    mutating func addFile(name: String, filename: String, mimeType: String, data: Data) {
        parts.append(.init(name: name, filename: filename, mimeType: mimeType, data: data))
    }
}

// MARK: - API Config
struct APIConfig {
    static var baseURL: URL = URL(string: "https://api-develop.coralclub.online/api/v1")!

    static let staticHeaders: [String: String] = [
        "Accept": "application/json"
    ]
    
    static var defaultHeaders: [String: String] {
        var headers = staticHeaders
        if !AppToken.bearerToken.isEmpty {
            headers["Authorization"] = AppToken.bearerToken
        }
        return headers
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

// MARK: - HTTP Body
enum HTTPBody {
    case jsonEncodable(Encodable)
    case jsonObject([String: Any])
    case multipart(MultipartFormData)
    case raw(Data, contentType: String)
}

// MARK: - Endpoint Protocol
protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: HTTPBody? { get }
    var requiresAuthentication: Bool { get }
}

// MARK: - Defaults
extension Endpoint {
    var baseURL: URL { APIConfig.baseURL }
    
    var headers: [String: String]? {
        requiresAuthentication ? APIConfig.defaultHeaders : APIConfig.staticHeaders
    }
    
    var queryItems: [URLQueryItem]? { nil }
    var body: HTTPBody? { nil }
    var requiresAuthentication: Bool { true }
}

// MARK: - Request Builder
struct RequestBuilder {
    static func buildRequest(from endpoint: Endpoint) throws -> URLRequest {
        var url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        
        if let queryItems = endpoint.queryItems {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            guard let newURL = components?.url else {
                throw NetworkError.invalidRequest(reason: "Invalid query parameters")
            }
            url = newURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Start with endpoint headers
        var headers = endpoint.headers ?? [:]
        
        // Handle body and content-type
        if let body = endpoint.body {
            let (bodyData, contentType) = try buildBody(body)
            request.httpBody = bodyData
            headers["Content-Type"] = contentType
        } else if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json"
        }
        
        request.allHTTPHeaderFields = headers
        
        #if DEBUG
        logRequest(request, endpoint: endpoint)
        #endif
        
        return request
    }
    
    private static func buildBody(_ body: HTTPBody) throws -> (Data, String) {
        switch body {
        case .jsonEncodable(let encodable):
            let data = try JSONEncoder().encode(AnyEncodable(encodable))
            return (data, "application/json")
            
        case .jsonObject(let obj):
            let data = try JSONSerialization.data(withJSONObject: obj, options: [])
            return (data, "application/json")
            
        case .raw(let data, let contentType):
            return (data, contentType)
            
        case .multipart(let form):
            let boundary = "Boundary-\(UUID().uuidString)"
            let data = buildMultipartBody(form: form, boundary: boundary)
            return (data, "multipart/form-data; boundary=\(boundary)")
        }
    }
    
    private static func buildMultipartBody(form: MultipartFormData, boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        for part in form.parts {
            body.append("--\(boundary)\(lineBreak)")
            
            if let filename = part.filename {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\(lineBreak)")
                body.append("Content-Type: \(part.mimeType ?? "application/octet-stream")\(lineBreak)\(lineBreak)")
            } else {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"\(lineBreak)\(lineBreak)")
            }
            
            body.append(part.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    #if DEBUG
    private static func logRequest(_ request: URLRequest, endpoint: Endpoint) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
        print("🔐 Requires Auth: \(endpoint.requiresAuthentication)")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 Headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let displayValue = key == "Authorization" ? "Bearer ***" : value
                print("   \(key): \(displayValue)")
            }
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString.prefix(500))")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    #endif
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - AnyEncodable
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}

// MARK: - Network Error
enum NetworkError: LocalizedError, Equatable {
    case invalidRequest(reason: String?)
    case invalidResponse
    case badRequest(message: String?)
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case serverError(statusCode: Int, message: String?)
    case decodingError(description: String)
    case encodingError(description: String)
    case urlSessionFailed(URLError)
    case timeout
    case noInternetConnection
    case unknownError(message: String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest(let reason):
            return "Invalid request: \(reason ?? "Unknown reason")"
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest(let message):
            return "Bad request (400): \(message ?? "Invalid parameters")"
        case .unauthorized(let message):
            return "Unauthorized (401): \(message ?? "Authentication required")"
        case .forbidden(let message):
            return "Forbidden (403): \(message ?? "Access denied")"
        case .notFound(let message):
            return "Not found (404): \(message ?? "Resource not found")"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Internal server error")"
        case .decodingError(let description):
            return "Failed to decode response: \(description)"
        case .encodingError(let description):
            return "Failed to encode request: \(description)"
        case .urlSessionFailed(let urlError):
            return "Network error: \(urlError.localizedDescription)"
        case .timeout:
            return "Request timeout"
        case .noInternetConnection:
            return "No internet connection"
        case .unknownError(let message):
            return "Unknown error: \(message ?? "Something went wrong")"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .unauthorized:
            return "Your session may have expired"
        case .forbidden:
            return "You don't have permission to access this resource"
        case .notFound:
            return "The requested resource was not found"
        case .serverError:
            return "The server encountered an error"
        case .noInternetConnection:
            return "Check your internet connection and try again"
        case .timeout:
            return "The request took too long to complete"
        default:
            return nil
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please sign in again"
        case .forbidden:
            return "Contact support if you believe this is an error"
        case .notFound:
            return "The resource may have been moved or deleted"
        case .serverError:
            return "Please try again later"
        case .noInternetConnection:
            return "Connect to the internet and try again"
        case .timeout:
            return "Check your connection and try again"
        case .decodingError:
            return "This may be a temporary issue. Try again later"
        default:
            return "Please try again"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest),
             (.invalidResponse, .invalidResponse),
             (.badRequest, .badRequest),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.timeout, .timeout),
             (.noInternetConnection, .noInternetConnection):
            return true
        case (.serverError(let lCode, _), .serverError(let rCode, _)):
            return lCode == rCode
        case (.urlSessionFailed(let lError), .urlSessionFailed(let rError)):
            return lError.code == rError.code
        default:
            return false
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .timeout, .noInternetConnection, .serverError:
            return true
        case .urlSessionFailed(let error):
            return error.code == .timedOut ||
                   error.code == .cannotConnectToHost ||
                   error.code == .networkConnectionLost
        default:
            return false
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .serverError(let code, _): return code
        default: return nil
        }
    }
    
    var shouldLogout: Bool {
        if case .unauthorized = self {
            return true
        }
        return false
    }
}

// MARK: - Error Response
struct ErrorResponse: Decodable {
    let message: String?
    let error: String?
    let detail: String?
    let errors: [String: [String]]?
    
    var displayMessage: String {
        if let message = message { return message }
        if let error = error { return error }
        if let detail = detail { return detail }
        if let errors = errors, !errors.isEmpty {
            return errors.values.flatMap { $0 }.joined(separator: ", ")
        }
        return "An error occurred"
    }
}

// MARK: - Network Manager
actor NetworkManager {
    static let shared = NetworkManager()
    
    private let urlSession: URLSession
    private var cache: [String: CacheEntry] = [:]
    
    private struct CacheEntry {
        let data: Data
        let timestamp: Date
        let ttl: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.urlSession = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        useCache: Bool = false,
        cacheTTL: TimeInterval = 300, // 5 minutes default
        type: T.Type
    ) async throws -> T {
        
        let request = try RequestBuilder.buildRequest(from: endpoint)
        let cacheKey = request.cacheKey
        
        // Check cache
        if useCache, let entry = cache[cacheKey], !entry.isExpired {
            do {
                return try decodeResponse(entry.data)
            } catch {
                cache.removeValue(forKey: cacheKey)
            }
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            #if DEBUG
            logResponse(httpResponse, data: data)
            #endif
            
            try handleHTTPResponse(httpResponse, data: data)
            
            // Cache successful responses
            if useCache && (200...299).contains(httpResponse.statusCode) {
                cache[cacheKey] = CacheEntry(
                    data: data,
                    timestamp: Date(),
                    ttl: cacheTTL
                )
            }
            
            return try decodeResponse(data)
            
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw handleURLError(urlError)
        } catch {
            throw NetworkError.unknownError(message: error.localizedDescription)
        }
    }
    
    private func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            let description = getDecodingErrorDescription(error)
            throw NetworkError.decodingError(description: description)
        }
    }
    
    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
        let message = errorResponse?.displayMessage
        
        switch response.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest(message: message)
        case 401:
            NotificationCenter.default.post(name: .userUnauthorized, object: nil)
            throw NetworkError.unauthorized(message: message)
        case 403:
            throw NetworkError.forbidden(message: message)
        case 404:
            throw NetworkError.notFound(message: message)
        case 500...599:
            throw NetworkError.serverError(statusCode: response.statusCode, message: message)
        default:
            throw NetworkError.unknownError(message: message)
        }
    }
    
    private func handleURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        default:
            return .urlSessionFailed(error)
        }
    }
    
    private func getDecodingErrorDescription(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else {
            return error.localizedDescription
        }
        
        switch decodingError {
        case .keyNotFound(let key, _):
            return "Missing key: '\(key.stringValue)'"
        case .typeMismatch(let type, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            return "Type mismatch for '\(type)' at: \(path)"
        case .valueNotFound(let type, let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            return "Missing value for '\(type)' at: \(path)"
        case .dataCorrupted(let context):
            let path = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            return "Data corrupted at: \(path)"
        @unknown default:
            return decodingError.localizedDescription
        }
    }
    
    #if DEBUG
    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("✅ Response: \(response.statusCode)")
        if let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📦 Body:\n\(prettyString.prefix(1000))")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    #endif
    
    func clearCache() {
        cache.removeAll()
    }
    
    func clearExpiredCache() {
        cache = cache.filter { !$0.value.isExpired }
    }
}

// MARK: - Retry Extension
extension NetworkManager {
    func requestWithRetry<T: Decodable>(
        _ endpoint: Endpoint,
        type: T.Type,
        maxRetries: Int = 3,
        useCache: Bool = false
    ) async throws -> T {
        
        var attempt = 0
        var lastError: NetworkError?
        
        while attempt <= maxRetries {
            do {
                return try await request(endpoint, useCache: useCache, type: type)
            } catch let error as NetworkError {
                lastError = error
                attempt += 1
                
                guard error.isRetryable && attempt <= maxRetries else {
                    throw error
                }
                
                let delay = pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
            } catch {
                throw NetworkError.unknownError(message: error.localizedDescription)
            }
        }
        
        throw lastError ?? NetworkError.unknownError(message: "Max retries exceeded")
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let userUnauthorized = Notification.Name("UserUnauthorizedNotification")
}

// MARK: - URLRequest Extension
private extension URLRequest {
    var cacheKey: String {
        let method = httpMethod ?? "GET"
        let url = url?.absoluteString ?? ""
        let bodyHash = httpBody?.hashValue ?? 0
        return "\(method):\(url):\(bodyHash)"
    }
}
