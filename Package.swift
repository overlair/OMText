// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OMText",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OMText",
            targets: ["OMText"]),
    ],
//    dependencies: [
//        .package(url: "https://github.com/krzyzanowskim/STTextView.git", from: "0.9.6")
//    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OMTextObjC",
            publicHeadersPath: "include"
//            path: "Sources/Internal"//,

        ),
        .target(
            name: "OMText",
            dependencies: ["OMTextObjC"]
        ),
        
        
        .testTarget(
            name: "OMTextTests",
            dependencies: ["OMText"]),
    ]
)
