// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "relux-analytics-appmetrica",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ReluxAnalyticsAppMetrica",
            targets: ["ReluxAnalyticsAppMetrica"]
        ),
    ],
    dependencies: [
        .package(path: "../../sdk"),
        .package(url: "https://github.com/appmetrica/appmetrica-sdk-ios.git", from: "5.9.0"),
    ],
    targets: [
        .target(
            name: "ReluxAnalyticsAppMetrica",
            dependencies: [
                .product(name: "ReluxAnalytics", package: "sdk"),
                .product(name: "AppMetricaCore", package: "appmetrica-sdk-ios"),
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
