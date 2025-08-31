// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "network_tester",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(name: "NetTesterLib", targets: ["NetTesterLib"]),
        .library(name: "NetTesterUIKit", targets: ["NetTesterUIKit"]),
        .library(name: "ApplePlatformChecks", targets: ["ApplePlatformChecks"]),
        .executable(name: "network-tester-cli", targets: ["network-tester-cli"]),
        .executable(name: "network-tester-tui", targets: ["network-tester-tui"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-dns-resolver", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/rensbreur/SwiftTUI", branch: "main"),
    ],
    targets: [
        .target(name: "NetTesterLib", dependencies: [
            .product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
        ]),
        .target(name: "NetTesterUIKit", dependencies: ["NetTesterLib"]),
        .target(name: "ApplePlatformChecks", dependencies: ["NetTesterLib"]),
        .executableTarget(
            name: "network-tester-cli",
            dependencies: [
                "NetTesterLib",
                .byNameItem(name: "ApplePlatformChecks", condition: .when(platforms: [.macOS])),
            ]),
        .executableTarget(
            name: "network-tester-tui",
            dependencies: [
                "NetTesterLib",
                "SwiftTUI",
                .byNameItem(name: "ApplePlatformChecks", condition: .when(platforms: [.macOS])),
            ]),
    ]
)
