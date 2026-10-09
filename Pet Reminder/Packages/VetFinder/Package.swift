// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "VetFinder",
    platforms: [.iOS(.v27)],
    products: [.library(name: "VetFinder", targets: ["VetFinder"])],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
    ],
    targets: [
        .target(name: "VetFinder", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
        .testTarget(name: "VetFinderTests", dependencies: ["VetFinder", .product(name: "Shared", package: "shared")]),
    ]
)
