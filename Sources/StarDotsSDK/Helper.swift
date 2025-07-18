import Foundation
import CommonCrypto

/// Helper functions for StarDots SDK
internal struct Helper {
    
    /// Generate request URL
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - path: API path
    /// - Returns: Complete URL string
    static func requestURL(endpoint: String, path: String) -> String {
        return "\(endpoint)\(path)"
    }
    
    /// Generate authentication request headers
    /// - Parameters:
    ///   - clientKey: Client key
    ///   - clientSecret: Client secret
    /// - Returns: Dictionary of headers
    static func makeHeaders(clientKey: String, clientSecret: String) -> [String: String] {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = String(Int(Date().timeIntervalSince1970 * 1000)) + String(10000 + Int.random(in: 0..<10000))
        
        let needSignStr = "\(timestamp)|\(clientSecret)|\(nonce)"
        let sign = needSignStr.md5().uppercased()
        
        let extraInfo: [String: String] = [
            "sdk": "true",
            "language": "swift",
            "version": Constants.sdkVersion,
            "os": getOSInfo(),
            "arch": getArchInfo()
        ]
        
        let extraData = try? JSONSerialization.data(withJSONObject: extraInfo)
        let extraString = extraData != nil ? String(data: extraData!, encoding: .utf8) ?? "" : ""
        
        return [
            "x-stardots-timestamp": timestamp,
            "x-stardots-nonce": nonce,
            "x-stardots-key": clientKey,
            "x-stardots-sign": sign,
            "x-stardots-extra": extraString
        ]
    }
    
    /// Send HTTP request
    /// - Parameters:
    ///   - method: HTTP method
    ///   - url: Request URL
    ///   - jsonPayload: JSON payload data
    ///   - headers: Request headers
    ///   - timeout: Request timeout
    /// - Returns: Response data, status code, and error
    static func sendRequest(
        method: String,
        url: String,
        jsonPayload: Data?,
        headers: [String: String],
        timeout: TimeInterval = Constants.defaultRequestTimeout
    ) async -> (response: Data?, statusCode: Int, error: Error?) {
        
        guard let requestURL = URL(string: url) else {
            return (nil, 0, StarDotsError.invalidURL)
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.timeoutInterval = timeout
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set payload if provided
        if let payload = jsonPayload {
            request.httpBody = payload
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            
            return (data, statusCode, nil)
        } catch {
            return (nil, 0, error)
        }
    }
    
    /// Send multipart form data request
    /// - Parameters:
    ///   - method: HTTP method
    ///   - url: Request URL
    ///   - formData: Form data dictionary
    ///   - fileData: File data
    ///   - fileName: File name
    ///   - headers: Request headers
    ///   - timeout: Request timeout
    /// - Returns: Response data, status code, and error
    static func sendMultipartRequest(
        method: String,
        url: String,
        formData: [String: String],
        fileData: Data?,
        fileName: String?,
        headers: [String: String],
        timeout: TimeInterval = Constants.defaultRequestTimeout
    ) async -> (response: Data?, statusCode: Int, error: Error?) {
        
        guard let requestURL = URL(string: url) else {
            return (nil, 0, StarDotsError.invalidURL)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.timeoutInterval = timeout
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Set custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Build multipart form data
        var body = Data()
        
        // Add form fields
        for (key, value) in formData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file data if provided
        if let fileData = fileData, let fileName = fileName {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            
            return (data, statusCode, nil)
        } catch {
            return (nil, 0, error)
        }
    }
    
    /// Get OS information
    /// - Returns: OS name string
    private static func getOSInfo() -> String {
        #if os(iOS)
        return "ios"
        #elseif os(macOS)
        return "macos"
        #elseif os(tvOS)
        return "tvos"
        #elseif os(watchOS)
        return "watchos"
        #else
        return "unknown"
        #endif
    }
    
    /// Get architecture information
    /// - Returns: Architecture string
    private static func getArchInfo() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "arm64"
        #elseif arch(arm)
        return "arm"
        #elseif arch(i386)
        return "i386"
        #else
        return "unknown"
        #endif
    }
}

// MARK: - String Extension for MD5

extension String {
    /// Calculate MD5 hash of the string
    /// Note: MD5 is used for API compatibility with StarDots server
    /// - Returns: MD5 hash string
    func md5() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { body -> String in
            // Using MD5 for API compatibility - this is required by the StarDots server
            #if compiler(>=5.9)
            CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
            #else
            CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
            #endif
            return ""
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - StarDots Error Types

/// StarDots SDK error types
public enum StarDotsError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(String)
    case decodingError(String)
    case encodingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        }
    }
} 