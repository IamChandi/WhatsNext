// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhatsNextShared",
    platforms: [
        .macOS(.v14),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "WhatsNextShared",
            targets: ["WhatsNextShared"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WhatsNextShared",
            dependencies: [],
            path: "Sources/WhatsNextShared",
            exclude: []
        ),
        .testTarget(
            name: "WhatsNextSharedTests",
            dependencies: ["WhatsNextShared"],
            path: "Tests/WhatsNextSharedTests"
        ),
    ]
)
