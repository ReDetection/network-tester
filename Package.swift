// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "network_tester",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(name: "NetTesterLib", targets: ["NetTesterLib"]),
        .executable(name: "network-tester", targets: ["network-tester"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "NetTesterLib"),
        .executableTarget(
            name: "network-tester",
            dependencies: ["NetTesterLib"]),
    ]
)
