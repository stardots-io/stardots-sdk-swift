// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarDotsSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "StarDotsSDK",
            targets: ["StarDotsSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StarDotsSDK",
            dependencies: []),
        .testTarget(
            name: "StarDotsSDKTests",
            dependencies: ["StarDotsSDK"]),
    ]
) 