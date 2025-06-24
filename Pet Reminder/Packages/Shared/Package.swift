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
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "6.2.0")
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
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .strictMemorySafety()
            ]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),
    ]
)
