// swift-tools-version: 6.4
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
    dependencies: [],
    targets: [
        .target(
            name: "Shared",
            dependencies: [],
            swiftSettings: [.strictMemorySafety()]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        )
    ]
)
