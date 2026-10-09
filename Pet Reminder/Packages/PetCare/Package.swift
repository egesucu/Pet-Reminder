// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "PetCare",
    platforms: [.iOS(.v27)],
    products: [.library(name: "PetCare", targets: ["PetCare"])],
    dependencies: [
        .package(path: "../Shared"),
    ],
    targets: [
        .target(name: "PetCare", dependencies: [.product(name: "Shared", package: "shared")], swiftSettings: [.strictMemorySafety()]),
        .testTarget(name: "PetCareTests", dependencies: ["PetCare", .product(name: "Shared", package: "shared")]),
    ]
)
