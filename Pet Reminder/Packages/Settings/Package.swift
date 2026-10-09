// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.iOS(.v27)],
    products: [.library(name: "Settings", targets: ["Settings"])],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
        .package(path: "../Reminders"),
        .package(path: "../PreviewSupport"),
    ],
    targets: [
        .target(name: "Settings", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui"), .product(name: "Reminders", package: "reminders"), .product(name: "PreviewSupport", package: "previewsupport")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
    ]
)
