// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HybridFlowKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "HybridFlowKit", targets: ["HybridFlowKit"])
    ],
    targets: [
        .target(
            name: "HybridFlowKit",
            dependencies: [],
            path: "Sources/HybridFlowKit",
            resources: []
        )
    ]
)
