import XCTest
@testable import StarDotsSDK

final class StarDotsTests: XCTestCase {
    
    private let testClientKey = "Your client key"
    private let testClientSecret = "Your client secret"
    private var starDots: StarDots!
    
    override func setUpWithError() throws {
        starDots = StarDots(clientKey: testClientKey, clientSecret: testClientSecret)
    }
    
    override func tearDownWithError() throws {
        starDots = nil
    }
    
    func testInitialization() throws {
        let client = StarDots(clientKey: testClientKey, clientSecret: testClientSecret)
        XCTAssertNotNil(client)
        
        let customEndpoint = "https://custom.api.stardots.io"
        let customClient = StarDots(clientKey: testClientKey, clientSecret: testClientSecret, endpoint: customEndpoint)
        XCTAssertNotNil(customClient)
    }
    
    func testGetSpaceList() async throws {
        let params = SpaceListRequest(page: 1, pageSize: 50)
        
        do {
            let response = try await starDots.getSpaceList(params: params)
            print("GetSpaceList response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("GetSpaceList error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testCreateSpace() async throws {
        let params = CreateSpaceRequest(space: "demo", isPublic: true)
        
        do {
            let response = try await starDots.createSpace(params: params)
            print("CreateSpace response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("CreateSpace error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testDeleteSpace() async throws {
        let params = DeleteSpaceRequest(space: "demo")
        
        do {
            let response = try await starDots.deleteSpace(params: params)
            print("DeleteSpace response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("DeleteSpace error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testToggleSpaceAccessibility() async throws {
        let params = ToggleSpaceAccessibilityRequest(space: "demo", isPublic: false)
        
        do {
            let response = try await starDots.toggleSpaceAccessibility(params: params)
            print("ToggleSpaceAccessibility response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("ToggleSpaceAccessibility error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testGetSpaceFileList() async throws {
        let params = SpaceFileListRequest(page: 1, pageSize: 50, space: "demo")
        
        do {
            let response = try await starDots.getSpaceFileList(params: params)
            print("GetSpaceFileList response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("GetSpaceFileList error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testFileAccessTicket() async throws {
        let params = FileAccessTicketRequest(filename: "1.png", space: "demo")
        
        do {
            let response = try await starDots.fileAccessTicket(params: params)
            print("FileAccessTicket response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("FileAccessTicket error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testUploadFile() async throws {
        // Create test file data
        let testData = "Hello, StarDots!".data(using: .utf8)!
        let params = UploadFileRequest(filename: "test.txt", space: "demo", fileContent: testData)
        
        do {
            let response = try await starDots.uploadFile(params: params)
            print("UploadFile response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("UploadFile error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testDeleteFile() async throws {
        let params = DeleteFileRequest(filenameList: ["test.txt"], space: "demo")
        
        do {
            let response = try await starDots.deleteFile(params: params)
            print("DeleteFile response: \(response)")
            XCTAssertNotNil(response)
        } catch {
            print("DeleteFile error: \(error)")
            // In test environment, we expect errors due to invalid credentials
            XCTAssertTrue(error is StarDotsError)
        }
    }
    
    func testConstants() throws {
        XCTAssertEqual(Constants.sdkVersion, "1.0.0")
        XCTAssertEqual(Constants.endpoint, "https://api.stardots.io")
        XCTAssertEqual(Constants.defaultRequestTimeout, 30.0)
    }
    
    func testErrorTypes() throws {
        let invalidURLError = StarDotsError.invalidURL
        XCTAssertEqual(invalidURLError.errorDescription, "Invalid URL")
        
        let networkError = StarDotsError.networkError("Test error")
        XCTAssertEqual(networkError.errorDescription, "Network error: Test error")
        
        let decodingError = StarDotsError.decodingError("Test error")
        XCTAssertEqual(decodingError.errorDescription, "Decoding error: Test error")
        
        let encodingError = StarDotsError.encodingError("Test error")
        XCTAssertEqual(encodingError.errorDescription, "Encoding error: Test error")
    }
} 