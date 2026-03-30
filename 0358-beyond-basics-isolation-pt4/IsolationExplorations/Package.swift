// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "IsolationExplorations",
    platforms: [.macOS(.v26)],
    products: [
        .library(
            name: "IsolationExplorations",
            targets: ["IsolationExplorations"]
        ),
    ],
    targets: [
        .target(
            name: "IsolationExplorations"
        ),
        .testTarget(
            name: "IsolationExplorationsTests",
            dependencies: ["IsolationExplorations"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
