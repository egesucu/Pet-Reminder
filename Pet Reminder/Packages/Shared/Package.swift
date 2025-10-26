// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Shared",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"],
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "7.0.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.62.1")
    ],
    targets: [
        .target(
            name: "Shared",
            dependencies: [
                "SFSafeSymbols"
            ],
            resources: [
                .process("Resources/LICENSE.md")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        )
    ]
)
