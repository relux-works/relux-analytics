// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "relux-analytics",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "ReluxAnalytics",
            targets: ["ReluxAnalytics"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/relux-works/swift-relux.git", from: "9.2.0"),
    ],
    targets: [
        .target(
            name: "ReluxAnalytics",
            dependencies: [
                .product(name: "Relux", package: "swift-relux"),
            ],
            swiftSettings: strictSwiftSettings
        ),
        .testTarget(
            name: "ReluxAnalyticsTests",
            dependencies: [
                "ReluxAnalytics",
            ],
            swiftSettings: strictSwiftSettings
        ),
    ]
)

let strictSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
    .enableUpcomingFeature("GlobalConcurrency"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonfrozenEnumExhaustivity"),
    .enableUpcomingFeature("RegionBasedIsolation"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]
