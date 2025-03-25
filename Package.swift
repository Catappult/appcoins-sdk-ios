// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCoinsSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AppCoinsSDK",
            targets: ["AppCoinsSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/web3swift-team/web3swift.git", .upToNextMinor(from: "3.2.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.5.1")),
        .package(url: "https://github.com/TakeScoop/SwiftyRSA.git", .upToNextMinor(from: "1.8.0")),
        .package(url: "https://github.com/devicekit/DeviceKit.git", .upToNextMinor(from: "4.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppCoinsSDK",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "SwiftyRSA", package: "SwiftyRSA"),
                .product(name: "DeviceKit", package: "DeviceKit")
            ],
            resources: [.process("Localization")])
    ]
)

