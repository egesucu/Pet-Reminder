// swift-tools-version: 6.4
import PackageDescription

// Public API consumers compile without @testable imports.
let package = Package(
    name: "ModuleTests",
    platforms: [.iOS(.v27)],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
        .package(path: "../PetCare"),
        .package(path: "../Reminders"),
        .package(path: "../Pets"),
        .package(path: "../Events"),
        .package(path: "../VetFinder"),
        .package(path: "../Settings"),
        .package(path: "../Intro"),
        .package(path: "../PreviewSupport"),
    ],
    targets: [
        .testTarget(name: "ModuleAPITests", dependencies: [.product(name: "Shared", package: "shared"), .product(name: "SharedUI", package: "sharedui"), .product(name: "PetCare", package: "petcare"), .product(name: "Reminders", package: "reminders"), .product(name: "Pets", package: "pets"), .product(name: "Events", package: "events"), .product(name: "VetFinder", package: "vetfinder"), .product(name: "Settings", package: "settings"), .product(name: "Intro", package: "intro"), .product(name: "PreviewSupport", package: "previewsupport")])
    ]
)
