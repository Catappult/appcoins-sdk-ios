// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCoinsSDK",
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
        .package(url: "https://github.com/web3swift-team/web3swift.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", branch: "main"),
        .package(url: "https://github.com/dmytro-anokhin/url-image.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/CSolanaM/SkeletonUI.git", branch: "master"),
        .package(url: "https://github.com/TakeScoop/SwiftyRSA.git", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/Adyen/adyen-ios.git", .exact("5.1.0")),
        .package(url: "https://github.com/exyte/ActivityIndicatorView.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppCoinsSDK",
            dependencies: [
                .product(name: "URLImage", package: "url-image"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "web3swift", package: "web3swift"),
                .product(name: "SkeletonUI", package: "SkeletonUI"),
                .product(name: "SwiftyRSA", package: "SwiftyRSA"),
                .product(name: "Adyen", package: "adyen-ios"),
                .product(name: "AdyenCard", package: "adyen-ios"),
                .product(name: "AdyenComponents", package: "adyen-ios"),
                .product(name: "AdyenSession", package: "adyen-ios"),
                .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView"),
            ]),
        .testTarget(
            name: "AppCoinsSDKTests",
            dependencies: ["AppCoinsSDK"]),
    ]
)

