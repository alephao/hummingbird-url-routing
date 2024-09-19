// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "hummingbird-url-routing",
  platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
  products: [
    .library(name: "HummingbirdURLRouting", targets: ["HummingbirdURLRouting"])
  ],
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0"),

  ],
  targets: [
    .target(
      name: "HummingbirdURLRouting",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(
      name: "HummingbirdURLRoutingTests",
      dependencies: [
        "HummingbirdURLRouting",
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdTesting", package: "hummingbird"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
  ]
)
