import Foundation

/// StarDots SDK protocol defining all available operations
public protocol StarDotsProtocol {
    /// Get space list data
    /// - Parameter params: Request parameters
    /// - Returns: Space list response
    func getSpaceList(params: SpaceListRequest) async throws -> SpaceListResponse
    
    /// Create a new space
    /// - Parameter params: Request parameters
    /// - Returns: Create space response
    func createSpace(params: CreateSpaceRequest) async throws -> CreateSpaceResponse
    
    /// Delete an existing space. Note that you must ensure that there are no files in this space, otherwise the deletion will fail
    /// - Parameter params: Request parameters
    /// - Returns: Delete space response
    func deleteSpace(params: DeleteSpaceRequest) async throws -> DeleteSpaceResponse
    
    /// Toggle the accessibility of a space
    /// - Parameter params: Request parameters
    /// - Returns: Toggle space accessibility response
    func toggleSpaceAccessibility(params: ToggleSpaceAccessibilityRequest) async throws -> ToggleSpaceAccessibilityResponse
    
    /// Get the list of files in the space. The list is sorted in descending order by file upload time
    /// - Parameter params: Request parameters
    /// - Returns: Space file list response
    func getSpaceFileList(params: SpaceFileListRequest) async throws -> SpaceFileListResponse
    
    /// Get the access ticket for the file. When the accessibility of the space is private, you need to bring the access ticket to access the files under the space, otherwise the request will be rejected
    /// - Parameter params: Request parameters
    /// - Returns: File access ticket response
    func fileAccessTicket(params: FileAccessTicketRequest) async throws -> FileAccessTicketResponse
    
    /// Upload the file to the space. Note that this request requires you to initiate the request in the form of a form
    /// - Parameter params: Request parameters
    /// - Returns: Upload file response
    func uploadFile(params: UploadFileRequest) async throws -> UploadFileResponse
    
    /// Delete files in the space. This interface supports batch operations
    /// - Parameter params: Request parameters
    /// - Returns: Delete file response
    func deleteFile(params: DeleteFileRequest) async throws -> DeleteFileResponse
}

/// StarDots SDK implementation
public class StarDots: StarDotsProtocol {
    private let endpoint: String
    private let clientKey: String
    private let clientSecret: String
    
    /// Initialize StarDots SDK instance
    /// - Parameters:
    ///   - clientKey: Your client key
    ///   - clientSecret: Your client secret
    ///   - endpoint: Optional custom endpoint (defaults to production endpoint)
    public init(clientKey: String, clientSecret: String, endpoint: String = Constants.endpoint) {
        self.clientKey = clientKey
        self.clientSecret = clientSecret
        self.endpoint = endpoint
    }
    
    // MARK: - Space Operations
    
    public func getSpaceList(params: SpaceListRequest) async throws -> SpaceListResponse {
        let queryItems = [
            URLQueryItem(name: "page", value: String(params.page)),
            URLQueryItem(name: "pageSize", value: String(params.pageSize))
        ]
        
        var urlComponents = URLComponents(string: Helper.requestURL(endpoint: endpoint, path: "/openapi/space/list"))!
        urlComponents.queryItems = queryItems
        
        let url = urlComponents.url!.absoluteString
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "GET",
            url: url,
            jsonPayload: nil,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(SpaceListResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func createSpace(params: CreateSpaceRequest) async throws -> CreateSpaceResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/space/create")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(params)
        } catch {
            throw StarDotsError.encodingError(error.localizedDescription)
        }
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "PUT",
            url: url,
            jsonPayload: jsonData,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(CreateSpaceResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func deleteSpace(params: DeleteSpaceRequest) async throws -> DeleteSpaceResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/space/delete")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(params)
        } catch {
            throw StarDotsError.encodingError(error.localizedDescription)
        }
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "DELETE",
            url: url,
            jsonPayload: jsonData,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(DeleteSpaceResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func toggleSpaceAccessibility(params: ToggleSpaceAccessibilityRequest) async throws -> ToggleSpaceAccessibilityResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/space/accessibility/toggle")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(params)
        } catch {
            throw StarDotsError.encodingError(error.localizedDescription)
        }
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "POST",
            url: url,
            jsonPayload: jsonData,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(ToggleSpaceAccessibilityResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - File Operations
    
    public func getSpaceFileList(params: SpaceFileListRequest) async throws -> SpaceFileListResponse {
        let queryItems = [
            URLQueryItem(name: "page", value: String(params.page)),
            URLQueryItem(name: "pageSize", value: String(params.pageSize)),
            URLQueryItem(name: "space", value: params.space)
        ]
        
        var urlComponents = URLComponents(string: Helper.requestURL(endpoint: endpoint, path: "/openapi/file/list"))!
        urlComponents.queryItems = queryItems
        
        let url = urlComponents.url!.absoluteString
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "GET",
            url: url,
            jsonPayload: nil,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(SpaceFileListResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func fileAccessTicket(params: FileAccessTicketRequest) async throws -> FileAccessTicketResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/file/ticket")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(params)
        } catch {
            throw StarDotsError.encodingError(error.localizedDescription)
        }
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "POST",
            url: url,
            jsonPayload: jsonData,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(FileAccessTicketResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func uploadFile(params: UploadFileRequest) async throws -> UploadFileResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/file/upload")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let formData = ["space": params.space]
        
        let (responseData, _, error) = await Helper.sendMultipartRequest(
            method: "PUT",
            url: url,
            formData: formData,
            fileData: params.fileContent,
            fileName: params.filename,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(UploadFileResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
    
    public func deleteFile(params: DeleteFileRequest) async throws -> DeleteFileResponse {
        let url = Helper.requestURL(endpoint: endpoint, path: "/openapi/file/delete")
        let headers = Helper.makeHeaders(clientKey: clientKey, clientSecret: clientSecret)
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(params)
        } catch {
            throw StarDotsError.encodingError(error.localizedDescription)
        }
        
        let (responseData, _, error) = await Helper.sendRequest(
            method: "DELETE",
            url: url,
            jsonPayload: jsonData,
            headers: headers
        )
        
        if let error = error {
            throw StarDotsError.networkError(error.localizedDescription)
        }
        
        guard let data = responseData else {
            throw StarDotsError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(DeleteFileResponse.self, from: data)
            return response
        } catch {
            throw StarDotsError.decodingError(error.localizedDescription)
        }
    }
} 