// swift-tools-version:6.0

//===----------------------------------------------------------------------===//
//
// This source file is part of the example package dealer open source project
//
// Copyright (c) 2015-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "dealer",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "dealer",
                    targets: ["dealer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/example-package-deckofplayingcards.git",
            from: "4.0.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "dealer",
            dependencies: [
                .product(name: "DeckOfPlayingCards",
                         package: "example-package-deckofplayingcards"),
                .product(name: "ArgumentParser",
                         package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "DealerTests",
            dependencies: [
                .byName(name: "dealer")
            ]),
    ]
)
