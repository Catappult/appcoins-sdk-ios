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
            targets: ["AppCoinsSDK", "PPRiskMagnes"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/web3swift-team/web3swift.git", .upToNextMinor(from: "3.2.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.5.1")),
        .package(url: "https://github.com/dmytro-anokhin/url-image.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/CSolanaM/SkeletonUI.git", .upToNextMinor(from: "2.0.1")),
        .package(url: "https://github.com/TakeScoop/SwiftyRSA.git", .upToNextMinor(from: "1.8.0")),
        .package(url: "https://github.com/Adyen/adyen-ios.git", exact: "5.1.0"),
        .package(url: "https://github.com/exyte/ActivityIndicatorView.git", .upToNextMinor(from: "1.1.0")),
        .package(url: "https://github.com/devicekit/DeviceKit.git", .upToNextMinor(from: "4.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppCoinsSDK",
            dependencies: [
                "IndicativeLibrary",
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
                .product(name: "DeviceKit", package: "DeviceKit")
            ],
            resources: [.process("Localization")]),
        .target(
            name: "IndicativeLibrary",
            path: "Sources/Indicative",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("Sources/Indicative"),
                .define("SWIFT_PACKAGE")
            ]),
        .binaryTarget(name: "PPRiskMagnes", path: "./Sources/AppCoinsSDK/Frameworks/PPRiskMagnes.xcframework")
        
    ]
)

