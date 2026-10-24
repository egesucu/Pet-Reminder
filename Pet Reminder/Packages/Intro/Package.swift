// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Intro",
    platforms: [.iOS(.v27)],
    products: [.library(name: "Intro", targets: ["Intro"])],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
    ],
    targets: [
        .target(name: "Intro", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
    ]
)
