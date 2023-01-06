// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "network-tester",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "network-tester", targets: ["network-tester"])
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "network-tester",
            dependencies: []),
    ]
)
