// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "Events",
    platforms: [.iOS(.v27)],
    products: [.library(
        name: "Events",
        targets: ["Events"]
    )],
    dependencies: [
        .package(path: "../Shared"),
        .package(path: "../SharedUI"),
    ],
    targets: [
        .target(
            name: "Events",
            dependencies: [
                .product(name: "Shared", package: "shared"),
                .product(name: "SharedUI", package: "sharedui")
            ],
            swiftSettings: [.strictMemorySafety(), .defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "EventsTests",
            dependencies: [
                "Events",
                .product(name: "Shared", package: "shared")
            ]
        ),
    ]
)
