// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Reminders",
    platforms: [.iOS(.v27)],
    products: [.library(name: "Reminders", targets: ["Reminders"])],
    dependencies: [
        .package(path: "../Shared"),
    ],
    targets: [
        .target(name: "Reminders", dependencies: [.product(name: "Shared", package: "shared")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
        .testTarget(name: "RemindersTests", dependencies: ["Reminders", .product(name: "Shared", package: "shared")]),
    ]
)
