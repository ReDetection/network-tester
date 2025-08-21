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
        .executable(name: "network-tester", targets: ["network-tester"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-dns-resolver", .upToNextMinor(from: "0.4.0")),
    ],
    targets: [
        .target(name: "NetTesterLib", dependencies: [
            .product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
        ]),
        .target(name: "NetTesterUIKit", dependencies: ["NetTesterLib"]),
        .executableTarget(
            name: "network-tester",
            dependencies: ["NetTesterLib"]),
    ]
)
