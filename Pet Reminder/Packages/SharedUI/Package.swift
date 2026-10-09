// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "SharedUI",
    platforms: [.iOS(.v27)],
    products: [.library(name: "SharedUI", targets: ["SharedUI"])],
    dependencies: [
        .package(path: "../Shared"),
    ],
    targets: [
        .target(name: "SharedUI", dependencies: [.product(name: "Shared", package: "shared")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
    ]
)
