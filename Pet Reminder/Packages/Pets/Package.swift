// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Pets",
    platforms: [.iOS(.v27)],
    products: [.library(name: "Pets", targets: ["Pets"])],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
        .package(path: "../PetCare"),
        .package(path: "../Reminders"),
        .package(path: "../PreviewSupport"),
    ],
    targets: [
        .target(name: "Pets", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui"), .product(name: "PetCare", package: "petcare"), .product(name: "Reminders", package: "reminders"), .product(name: "PreviewSupport", package: "previewsupport")], swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]),
        .testTarget(name: "PetsTests", dependencies: ["Pets", .product(name: "Shared", package: "shared")]),
    ]
)

// Tests cover feeding history and durable navigation identity.
