// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Gormsson",
    products: [
        .library(
            name: "Gormsson",
            targets: ["Gormsson"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MoveUpwards/Nevanlinna.git", from: "0.3.4")
    ],
    targets: [
        .target(
            name: "Gormsson",
            dependencies: [],
            path: "Gormsson/Source"
        ),
    ]
)
