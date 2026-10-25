// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TallyCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TallyCore", targets: ["TallyCore"])
    ],
    targets: [
        .target(name: "TallyCore"),
        .testTarget(name: "TallyCoreTests", dependencies: ["TallyCore"])
    ]
)
