// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "OCBCKit",
    platforms: [
        .watchOS(.v26),
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "OCBCKit",
            targets: ["OCBCKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "OCBCKit",
            dependencies: [
                "AppCore",
                "DesignSystem",
                "HomeFeature",
                "BalanceFeature",
                "QrisFeature",
                "FundTransferFeature",
                "PaymentFeature"
            ]
        ),
        .target(
            name: "AppCore",
            dependencies: [
                "Networking",
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        ),
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Networking"
        ),
        .target(
            name: "BalanceCore",
            dependencies: [
                "AppCore",
                "Networking",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "QrisCore",
            dependencies: [
                "AppCore",
                "Networking",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "AppCore",
                "DesignSystem"
            ]
        ),
        .target(
            name: "BalanceFeature",
            dependencies: [
                "AppCore",
                "BalanceCore",
                "DesignSystem",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "QrisFeature",
            dependencies: [
                "AppCore",
                "QrisCore",
                "DesignSystem",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "FundTransferFeature",
            dependencies: [
                "AppCore",
                "DesignSystem"
            ]
        ),
        .target(
            name: "PaymentFeature",
            dependencies: [
                "AppCore",
                "DesignSystem"
            ]
        ),
        .testTarget(
            name: "OCBCKitTests",
            dependencies: ["OCBCKit"]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        ),
        .testTarget(
            name: "BalanceCoreTests",
            dependencies: ["BalanceCore", "Networking"]
        ),
        .testTarget(
            name: "BalanceFeatureTests",
            dependencies: [
                "BalanceFeature",
                "BalanceCore",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        ),
        .testTarget(
            name: "QrisCoreTests",
            dependencies: ["QrisCore", "Networking"]
        ),
        .testTarget(
            name: "QrisFeatureTests",
            dependencies: [
                "QrisFeature",
                "QrisCore",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        )
    ]
)
