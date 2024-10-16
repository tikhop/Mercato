// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Mercato",
    platforms: [
        .iOS(.v15), .tvOS(.v15), .watchOS("8.0"),
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
