// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "PreviewSupport",
    platforms: [.iOS(.v27)],
    products: [.library(name: "PreviewSupport", targets: ["PreviewSupport"])],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
    ],
    targets: [
        .target(name: "PreviewSupport", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
    ]
)
