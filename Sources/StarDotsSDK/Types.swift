import Foundation

// MARK: - Common Response Types

/// Common HTTP response body
/// All interface responses maintain a unified data structure
public struct CommonResponse: Codable {
    /// Service response code
    public let code: Int
    /// Message prompt of the operation result
    public let message: String
    /// A unique number for the request, which can be used for troubleshooting
    public let requestId: String
    /// Indicates whether the business operation is successful
    public let success: Bool
    /// Server millisecond timestamp
    public let timestamp: Int64
    /// Business data field. This field can be of any data type
    public let data: [String: Any]?
    
    private enum CodingKeys: String, CodingKey {
        case code, message, requestId, success, timestamp, data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        requestId = try container.decode(String.self, forKey: .requestId)
        success = try container.decode(Bool.self, forKey: .success)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        
        // Handle data field which can be any type
        if let dataValue = try? container.decode(AnyCodable.self, forKey: .data) {
            data = dataValue.value as? [String: Any]
        } else {
            data = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(success, forKey: .success)
        try container.encode(timestamp, forKey: .timestamp)
        if let data = data {
            try container.encode(AnyCodable(data), forKey: .data)
        }
    }
}

/// Helper struct to handle Any type in Codable
private struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Pagination Types

/// Paginator request parameters
public struct PaginationRequest: Codable {
    /// Page number, default value is 1
    public var page: Int = 1
    /// The number of entries per page ranges from 1 to 100, and the default value is 20
    public var pageSize: Int = 20
    
    public init(page: Int = 1, pageSize: Int = 20) {
        self.page = page
        self.pageSize = pageSize
    }
}

/// Paginator response data structure
public struct PaginationResponse: Codable {
    /// Page number, default value is 1
    public let page: Int
    /// The number of entries per page ranges from 1 to 100, and the default value is 20
    public let pageSize: Int
    /// The total number of entries
    public let totalCount: Int64
}

// MARK: - Space Types

/// Get space list request parameters
public struct SpaceListRequest: Codable {
    public var page: Int = 1
    public var pageSize: Int = 20
    
    public init(page: Int = 1, pageSize: Int = 20) {
        self.page = page
        self.pageSize = pageSize
    }
}

/// Get space list response data structure
public struct SpaceListResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
    public let data: [SpaceInfo]
}

/// Space information data structure
public struct SpaceInfo: Codable {
    /// The name of the space
    public let name: String
    /// Whether the accessibility of the space is false
    public let isPublic: Bool
    /// The system timestamp in seconds when the space was created. The time zone is UTC+8
    public let createdAt: Int64
    /// The number of files in this space
    public let fileCount: Int64
    
    private enum CodingKeys: String, CodingKey {
        case name, isPublic = "public", createdAt, fileCount
    }
}

/// Create space request parameters
public struct CreateSpaceRequest: Codable {
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    /// Specifies whether the space is publicly accessible. The default value is false
    public let isPublic: Bool
    
    private enum CodingKeys: String, CodingKey {
        case space, isPublic = "public"
    }
    
    public init(space: String, isPublic: Bool = false) {
        self.space = space
        self.isPublic = isPublic
    }
}

/// Create space response data structure
public struct CreateSpaceResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
}

/// Delete space request parameters
public struct DeleteSpaceRequest: Codable {
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    
    public init(space: String) {
        self.space = space
    }
}

/// Delete space response data structure
public struct DeleteSpaceResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
}

/// ToggleSpaceAccessibility space request parameters
public struct ToggleSpaceAccessibilityRequest: Codable {
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    /// Specifies whether the space is publicly accessible. The default value is false
    public let isPublic: Bool
    
    private enum CodingKeys: String, CodingKey {
        case space, isPublic = "public"
    }
    
    public init(space: String, isPublic: Bool) {
        self.space = space
        self.isPublic = isPublic
    }
}

/// ToggleSpaceAccessibility space response data structure
public struct ToggleSpaceAccessibilityResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
}

// MARK: - File Types

/// Get space file list request parameters
public struct SpaceFileListRequest: Codable {
    public var page: Int = 1
    public var pageSize: Int = 20
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    
    public init(page: Int = 1, pageSize: Int = 20, space: String) {
        self.page = page
        self.pageSize = pageSize
        self.space = space
    }
}

/// Get space file list response data structure
public struct SpaceFileListResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
    public let data: FileListData
}

public struct FileListData: Codable {
    public let list: [FileInfo]
}

/// File information data structure
public struct FileInfo: Codable {
    /// The name of the file
    public let name: String
    /// The size of the file in bytes
    public let byteSize: Int64
    /// File size, formatted for readability
    public let size: String
    /// The timestamp of the file upload in seconds. The time zone is UTC+8
    public let uploadedAt: Int64
    /// The access address of the file. Note that if the accessibility of the space is private, this field value will carry the access ticket, which is valid for 20 seconds
    public let url: String
}

/// Get file access ticket request parameters
public struct FileAccessTicketRequest: Codable {
    /// The name of the file
    public let filename: String
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    
    public init(filename: String, space: String) {
        self.filename = filename
        self.space = space
    }
}

/// Get file access ticket response data structure
public struct FileAccessTicketResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
    public let data: TicketData
}

public struct TicketData: Codable {
    public let ticket: String
}

/// Upload file request parameters
public struct UploadFileRequest: Codable {
    /// The name of the file
    public let filename: String
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    /// The file bytes content
    public let fileContent: Data
    
    public init(filename: String, space: String, fileContent: Data) {
        self.filename = filename
        self.space = space
        self.fileContent = fileContent
    }
}

/// Upload file response data structure
public struct UploadFileResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
    public let data: UploadFileData
}

public struct UploadFileData: Codable {
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    /// The name of the file
    public let filename: String
    /// The access address of the file. Note that if the accessibility of the space is private, this field value will carry the access ticket, which is valid for 20 seconds
    public let url: String
}

/// Delete file request parameters
public struct DeleteFileRequest: Codable {
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let filenameList: [String]
    /// The name of the space. It can only be a combination of letters or numbers, and the length is 4 to 15 characters
    public let space: String
    
    public init(filenameList: [String], space: String) {
        self.filenameList = filenameList
        self.space = space
    }
}

/// Delete file response data structure
public struct DeleteFileResponse: Codable {
    public let code: Int
    public let message: String
    public let requestId: String
    public let success: Bool
    public let timestamp: Int64
} 