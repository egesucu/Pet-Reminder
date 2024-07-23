// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UI",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]
            )
    ],
    dependencies: [
        .package(
            name: "SharedModels", 
            path: "../SharedModels"
        )
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: ["SharedModels"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ],
            swiftSettings: [
                .swiftLanguageVersion(.v6),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_INTERNAL_IMPORTS_BY_DEFAULT"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_DISABLE_OUTWARD_ACTOR_ISOLATION"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_IMPLICIT_OPEN_EXISTENTIALS"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_IMPORT_OBJC_FORWARD_DECLS"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_GLOBAL_CONCURRENCY"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_REGION_BASED_ISOLATION"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY"),
                .enableExperimentalFeature("StrictConcurrency=complete", .when(platforms: [.iOS]))
            ]
        )
    ]
)
