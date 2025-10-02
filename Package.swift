// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "RestaurantAIKit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12)
  ],
  products: [
    .library(name: "RestaurantAIKit", targets: ["RestaurantAIKit"]),
    .library(name: "RestaurantAIUI", targets: ["RestaurantAIUI"])
  ],
  targets: [
    .target(
      name: "RestaurantAIKit",
      dependencies: [],
      path: "Sources/RestaurantAIKit"
    ),
    .target(
      name: "RestaurantAIUI",
      dependencies: ["RestaurantAIKit"],
      path: "Sources/RestaurantAIUI"
    ),
    .testTarget(
      name: "RestaurantAIKitTests",
      dependencies: ["RestaurantAIKit"],
      path: "Tests/RestaurantAIKitTests"
    )
  ]
)

