// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedModels",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "SharedModels",
            targets: ["SharedModels"]
        )
    ],
    targets: [
        .target(
            name: "SharedModels"
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"]
        )
    ]
)
