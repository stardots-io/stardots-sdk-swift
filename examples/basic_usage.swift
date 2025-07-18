import Foundation
import StarDotsSDK

// Example usage of StarDots Swift SDK
@main
struct BasicUsageExample {
    
    static func main() async {
        // Initialize the SDK with your credentials
        let clientKey = "Your client key"
        let clientSecret = "Your client secret"
        let starDots = StarDots(clientKey: clientKey, clientSecret: clientSecret)
        
        print("StarDots Swift SDK Example")
        print("==========================")
        
        // Example 1: Get space list
        await getSpaceList(starDots: starDots)
        
        // Example 2: Create a new space
        await createSpace(starDots: starDots)
        
        // Example 3: Get files in a space
        await getSpaceFileList(starDots: starDots)
        
        // Example 4: Upload a file
        await uploadFile(starDots: starDots)
        
        // Example 5: Get file access ticket
        await getFileAccessTicket(starDots: starDots)
        
        // Example 6: Delete a file
        await deleteFile(starDots: starDots)
        
        // Example 7: Toggle space accessibility
        await toggleSpaceAccessibility(starDots: starDots)
        
        // Example 8: Delete a space
        await deleteSpace(starDots: starDots)
    }
    
    // MARK: - Space Operations
    
    static func getSpaceList(starDots: StarDots) async {
        print("\n1. Getting space list...")
        
        let params = SpaceListRequest(page: 1, pageSize: 20)
        
        do {
            let response = try await starDots.getSpaceList(params: params)
            print("✅ Success: Found \(response.data.count) spaces")
            
            for space in response.data {
                print("   - Space: \(space.name), Public: \(space.isPublic), Files: \(space.fileCount)")
            }
        } catch {
            print("❌ Error getting space list: \(error)")
        }
    }
    
    static func createSpace(starDots: StarDots) async {
        print("\n2. Creating a new space...")
        
        let spaceName = "demo-\(Int.random(in: 1000...9999))"
        let params = CreateSpaceRequest(space: spaceName, isPublic: true)
        
        do {
            let response = try await starDots.createSpace(params: params)
            print("✅ Success: Created space '\(spaceName)'")
            print("   - Response code: \(response.code)")
            print("   - Message: \(response.message)")
        } catch {
            print("❌ Error creating space: \(error)")
        }
    }
    
    static func toggleSpaceAccessibility(starDots: StarDots) async {
        print("\n3. Toggling space accessibility...")
        
        let params = ToggleSpaceAccessibilityRequest(space: "demo", isPublic: false)
        
        do {
            let response = try await starDots.toggleSpaceAccessibility(params: params)
            print("✅ Success: Toggled space accessibility")
            print("   - Response code: \(response.code)")
            print("   - Message: \(response.message)")
        } catch {
            print("❌ Error toggling space accessibility: \(error)")
        }
    }
    
    static func deleteSpace(starDots: StarDots) async {
        print("\n4. Deleting a space...")
        
        let params = DeleteSpaceRequest(space: "demo")
        
        do {
            let response = try await starDots.deleteSpace(params: params)
            print("✅ Success: Deleted space 'demo'")
            print("   - Response code: \(response.code)")
            print("   - Message: \(response.message)")
        } catch {
            print("❌ Error deleting space: \(error)")
        }
    }
    
    // MARK: - File Operations
    
    static func getSpaceFileList(starDots: StarDots) async {
        print("\n5. Getting space file list...")
        
        let params = SpaceFileListRequest(page: 1, pageSize: 20, space: "demo")
        
        do {
            let response = try await starDots.getSpaceFileList(params: params)
            print("✅ Success: Found \(response.data.list.count) files in space 'demo'")
            
            for file in response.data.list {
                print("   - File: \(file.name), Size: \(file.size), URL: \(file.url)")
            }
        } catch {
            print("❌ Error getting space file list: \(error)")
        }
    }
    
    static func uploadFile(starDots: StarDots) async {
        print("\n6. Uploading a file...")
        
        // Create sample file content
        let fileContent = "Hello, StarDots! This is a test file uploaded from Swift SDK.".data(using: .utf8)!
        let params = UploadFileRequest(filename: "test.txt", space: "demo", fileContent: fileContent)
        
        do {
            let response = try await starDots.uploadFile(params: params)
            print("✅ Success: Uploaded file 'test.txt'")
            print("   - Space: \(response.data.space)")
            print("   - Filename: \(response.data.filename)")
            print("   - URL: \(response.data.url)")
        } catch {
            print("❌ Error uploading file: \(error)")
        }
    }
    
    static func getFileAccessTicket(starDots: StarDots) async {
        print("\n7. Getting file access ticket...")
        
        let params = FileAccessTicketRequest(filename: "test.txt", space: "demo")
        
        do {
            let response = try await starDots.fileAccessTicket(params: params)
            print("✅ Success: Got access ticket")
            print("   - Ticket: \(response.data.ticket)")
        } catch {
            print("❌ Error getting file access ticket: \(error)")
        }
    }
    
    static func deleteFile(starDots: StarDots) async {
        print("\n8. Deleting a file...")
        
        let params = DeleteFileRequest(filenameList: ["test.txt"], space: "demo")
        
        do {
            let response = try await starDots.deleteFile(params: params)
            print("✅ Success: Deleted file 'test.txt'")
            print("   - Response code: \(response.code)")
            print("   - Message: \(response.message)")
        } catch {
            print("❌ Error deleting file: \(error)")
        }
    }
}

// MARK: - Error Handling Example

extension BasicUsageExample {
    
    static func demonstrateErrorHandling() async {
        print("\nError Handling Examples")
        print("=======================")
        
        let starDots = StarDots(clientKey: "invalid", clientSecret: "invalid")
        
        // Example of handling different error types
        do {
            let params = SpaceListRequest()
            let response = try await starDots.getSpaceList(params: params)
            print("Unexpected success: \(response)")
        } catch StarDotsError.invalidURL {
            print("❌ Invalid URL error")
        } catch StarDotsError.networkError(let message) {
            print("❌ Network error: \(message)")
        } catch StarDotsError.decodingError(let message) {
            print("❌ Decoding error: \(message)")
        } catch StarDotsError.encodingError(let message) {
            print("❌ Encoding error: \(message)")
        } catch {
            print("❌ Unknown error: \(error)")
        }
    }
} 