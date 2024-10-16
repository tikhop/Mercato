// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Mercato",
    platforms: [
        .iOS("15.4"), .tvOS("17.0"), .watchOS("10.0"), .macOS("12.3"), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Mercato",
            targets: ["Mercato"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Mercato",
            dependencies: []
        ),
        .testTarget(
            name: "MercatoTests",
            dependencies: ["Mercato"]
        ),
    ]
)
