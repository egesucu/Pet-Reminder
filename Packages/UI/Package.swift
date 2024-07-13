// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]),
    ],
    dependencies: [
        .package(name: "SharedModels", path: "../SharedModels")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: ["SharedModels"],
            resources: [
                .process("Resources/Assets.xcassets")
            ],
            swiftSettings: [.define("ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS")]
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["UI", "SharedModels"]
        ),
    ]
)
