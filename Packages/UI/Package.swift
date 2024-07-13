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
            dependencies: ["SharedModels"]
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"]
        ),
    ]
)
