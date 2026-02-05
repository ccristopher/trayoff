// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TrayOff",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "TrayOff",
            targets: ["TrayOff"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TrayOff",
            dependencies: [],
            path: "Retainer Tracker"
        ),
        .testTarget(
            name: "Retainer TrackerTests",
            dependencies: ["TrayOff"],
            path: "Retainer TrackerTests"
        )
    ]
)
