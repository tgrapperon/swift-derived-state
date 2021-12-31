// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "swift-derived-state",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableState",
      targets: ["ComposableState"]
    ),
    .library(
      name: "DerivedState",
      targets: ["DerivedState"]
    ),
    .library(
      name: "IdentifiedCollectionsDerivedState",
      targets: ["IdentifiedCollectionsDerivedState"]
    ),
  ],
  dependencies: [
    .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", .branch("main")),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.3.2"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.21.0"),
  ],
  targets: [
    .target(
      name: "ComposableState",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "DerivedState",
        "IdentifiedCollectionsDerivedState",
      ]
    ),
    .testTarget(
      name: "ComposableStateTests",
      dependencies: ["ComposableState"]
    ),
    
    .target(name: "DerivedState"),
    .testTarget(
      name: "DerivedStateTests",
      dependencies: ["DerivedState"]
    ),

    .target(
      name: "IdentifiedCollectionsDerivedState",
      dependencies: [
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        "DerivedState",
      ]
    ),
    .testTarget(
      name: "IdentifiedCollectionsDerivedStateTests",
      dependencies: ["IdentifiedCollectionsDerivedState"]
    ),
    
    .executableTarget(
      name: "swift-derived-state-benchmark",
      dependencies: [
        .product(name: "Benchmark", package: "Benchmark"),
        "DerivedState",
        "IdentifiedCollectionsDerivedState",
      ]
    ),
  ]
)
