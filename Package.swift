// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "relux-analytics",
    platforms: [
           .iOS(.v15),
    ],
    products: [
        .library(
            name: "ReluxAnalytics",
            targets: ["ReluxAnalytics"]),
    ],
    dependencies: [
        .package(url: "git@github.com:relux-works/swift-relux.git", from: "5.0.1"),
    ],
    targets: [
        .target(
            name: "ReluxAnalytics",
            dependencies: [
                .product(name: "Relux", package: "swift-relux"),
            ]
        )
    ]
)
