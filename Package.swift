// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Gormsson",
    platforms: [
        .iOS(.v10), .macOS(.v10_13)
    ],
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
            dependencies: ["Nevanlinna"],
            path: "Gormsson/Source"
        ),
    ]
)
