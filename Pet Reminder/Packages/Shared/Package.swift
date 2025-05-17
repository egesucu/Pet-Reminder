// swift-tools-version: 6.1

import PackageDescription

extension SwiftSetting {
    /// Introduce existential `any`
    /// - Version: Swift 5.6
    /// - Since: SwiftPM 5.8
    /// - SeeAlso: [SE-0335: Introduce existential `any`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md)
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")
}

extension SwiftSetting: @retroactive CaseIterable {
    public static var allCases: [Self] {
        [
            .existentialAny
        ]
    }
}

let package = Package(
    name: "Shared",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "6.2.0")
    ],
    targets: [
        .target(
            name: "Shared",
            dependencies: [
                "SFSafeSymbols"
            ],
            resources: [
                .process("Resources/LICENSE.md")
            ]
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["Shared"]
        ),
    ]
)

package
    .targets
    .filter { ![.system, .binary, .plugin].contains($0.type) }
    .forEach { $0.swiftSettings = SwiftSetting.allCases }
