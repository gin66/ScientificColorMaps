// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ScientificColorMaps",
  platforms: [
    .macOS(.v13),
    .iOS(.v13),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ScientificColorMaps",
      targets: ["ScientificColorMaps"])
  ],
  dependencies: [
    .package(url: "https://github.com/chrs1885/WCAG-Colors.git", from: "1.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ScientificColorMaps"),
    .executableTarget(
      name: "CodeGenerator",
      dependencies: []),
    .testTarget(
      name: "ScientificColorMapsTests",
      dependencies: ["ScientificColorMaps"]
    ),
    .executableTarget(
      name: "GenerateDiagrams",
      dependencies: [
	"ScientificColorMaps", "WCAG-Colors"
      ]
    ),
  ]
)
