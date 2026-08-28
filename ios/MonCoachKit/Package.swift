// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MonCoachKit",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],
    products: [
        .library(name: "MonCoachKit", targets: ["MonCoachKit"])
    ],
    targets: [
        .target(
            name: "MonCoachKit",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "MonCoachKitTests",
            dependencies: ["MonCoachKit"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
