// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Integrator",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Integrator",
            targets: ["Integrator"]
        ),
        .library(
            name: "Acquisitor",
            targets: ["Acquisitor"]
        ),
        .library(
            name: "Analytical",
            targets: ["Analytical"]
        ),
        .library(
            name: "IntegratorDefaults",
            targets: ["IntegratorDefaults"]
        ),
        .library(
            name: "IntegratorClient",
            targets: ["IntegratorClient"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.17.0")
        ),
        .package(
            url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework",
            .exact("6.4.0")
        ),
        .package(
            url: "https://github.com/bizz84/SwiftyStoreKit.git",
            .upToNextMajor(from: "0.16.0")
        ),
        .package(
            url: "https://github.com/evgenyneu/keychain-swift.git",
            .upToNextMajor(from: "20.0.0")
        ),
        .package(
            url: "https://github.com/Swiftify-Corp/IHProgressHUD.git",
            .upToNextMajor(from: "0.1.5")
        )
    ],
    targets: [
        .target(
            name: "IntegratorDefaults",
            path: "Sources/IntegratorDefaults"
        ),
        .target(
            name: "IntegratorClient",
            path: "Sources/IntegratorClient"
        ),
        .target(
            name: "Integrator",
            dependencies: [
                "Acquisitor",
                "IntegratorDefaults",
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "Acquisitor",
            dependencies: [
                "Analytical",
                "IntegratorDefaults",
                .product(name: "IHProgressHUD", package: "IHProgressHUD"),
                .product(name: "SwiftyStoreKit", package: "SwiftyStoreKit"),
                .product(name: "KeychainSwift", package: "keychain-swift")
            ],
            path: "Sources/Acquisitor"
        ),
        .target(
            name: "Analytical",
            dependencies: [
                "IntegratorDefaults",
                "IntegratorClient",
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Analytical"
        )
    ]
)
