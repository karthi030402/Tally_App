// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TallyCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TallyCore", targets: ["TallyCore"]),
        .library(name: "TallyStorage", targets: ["TallyStorage"])
    ],
    targets: [
        .target(name: "TallyCore"),
        .target(name: "TallyStorage", dependencies: ["TallyCore"]),
        .testTarget(name: "TallyCoreTests", dependencies: ["TallyCore"]),
        .testTarget(name: "TallyStorageTests", dependencies: ["TallyStorage", "TallyCore"])
    ]
)
