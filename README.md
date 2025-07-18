<div align="center">
    <h1><img src="logo.png" alt="sailboat-solid" title="sailboat-solid" width="300" /></h1>
</div> 

# StarDots-SDK-Swift  

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/github/license/stardots-io/stardots-sdk-swift.svg?style=flat)](LICENSE)  

### Introduction  
This project is used to help developers quickly access the StarDots platform and is written in Swift.  

### Requirements  
- Swift 5.7+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Xcode 14.0+

### Installation  

#### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/stardots-io/stardots-sdk-swift.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/stardots-io/stardots-sdk-swift.git`
3. Select the version you want to use

#### Manual Installation

1. Clone the repository
2. Add the `Sources/StarDotsSDK` folder to your project
3. Import the module in your Swift files

### Usage  

#### Basic Setup

```swift
import StarDotsSDK

// Initialize the SDK with your credentials
let clientKey = "Your client key"
let clientSecret = "Your client secret"
let starDots = StarDots(clientKey: clientKey, clientSecret: clientSecret)
```

#### Space Operations

```swift
// Get space list
let spaceListParams = SpaceListRequest(page: 1, pageSize: 20)
let spaceListResponse = try await starDots.getSpaceList(params: spaceListParams)

// Create a new space
let createSpaceParams = CreateSpaceRequest(space: "my-space", isPublic: true)
let createSpaceResponse = try await starDots.createSpace(params: createSpaceParams)

// Delete a space
let deleteSpaceParams = DeleteSpaceRequest(space: "my-space")
let deleteSpaceResponse = try await starDots.deleteSpace(params: deleteSpaceParams)

// Toggle space accessibility
let toggleParams = ToggleSpaceAccessibilityRequest(space: "my-space", isPublic: false)
let toggleResponse = try await starDots.toggleSpaceAccessibility(params: toggleParams)
```

#### File Operations

```swift
// Get files in a space
let fileListParams = SpaceFileListRequest(page: 1, pageSize: 20, space: "my-space")
let fileListResponse = try await starDots.getSpaceFileList(params: fileListParams)

// Upload a file
let fileData = "Hello, StarDots!".data(using: .utf8)!
let uploadParams = UploadFileRequest(filename: "test.txt", space: "my-space", fileContent: fileData)
let uploadResponse = try await starDots.uploadFile(params: uploadParams)

// Get file access ticket
let ticketParams = FileAccessTicketRequest(filename: "test.txt", space: "my-space")
let ticketResponse = try await starDots.fileAccessTicket(params: ticketParams)

// Delete files
let deleteParams = DeleteFileRequest(filenameList: ["test.txt"], space: "my-space")
let deleteResponse = try await starDots.deleteFile(params: deleteParams)
```

#### Error Handling

```swift
do {
    let response = try await starDots.getSpaceList(params: SpaceListRequest())
    print("Success: \(response)")
} catch StarDotsError.invalidURL {
    print("Invalid URL error")
} catch StarDotsError.networkError(let message) {
    print("Network error: \(message)")
} catch StarDotsError.decodingError(let message) {
    print("Decoding error: \(message)")
} catch StarDotsError.encodingError(let message) {
    print("Encoding error: \(message)")
} catch {
    print("Unknown error: \(error)")
}
```

### API Reference

#### StarDots Class

The main class for interacting with the StarDots API.

**Initialization:**
```swift
init(clientKey: String, clientSecret: String, endpoint: String = Constants.endpoint)
```

**Methods:**
- `getSpaceList(params:)` - Get list of spaces
- `createSpace(params:)` - Create a new space
- `deleteSpace(params:)` - Delete an existing space
- `toggleSpaceAccessibility(params:)` - Toggle space accessibility
- `getSpaceFileList(params:)` - Get files in a space
- `uploadFile(params:)` - Upload a file
- `fileAccessTicket(params:)` - Get file access ticket
- `deleteFile(params:)` - Delete files

#### Request/Response Types

All request and response types are defined in the `Types.swift` file and conform to `Codable` for easy JSON serialization/deserialization.

### Examples

See the `examples/` directory for complete usage examples.

### Documentation  
[https://stardots.io/en/documentation/openapi](https://stardots.io/en/documentation/openapi)  

### Homepage  
[https://stardots.io](https://stardots.io)  

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 