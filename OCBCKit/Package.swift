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
            name: "AppCore"
        ),
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")]
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
                "DesignSystem"
            ]
        ),
        .target(
            name: "QrisFeature",
            dependencies: [
                "AppCore",
                "DesignSystem"
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
        )
    ]
)
