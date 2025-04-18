// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .iOS(.v18)
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
            ]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),
    ]
)
