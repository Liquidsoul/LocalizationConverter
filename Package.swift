// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalizationConverter",
    products: [
        .library(
            name: "LocalizationConverter",
            targets: ["LocalizationConverter"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1")
    ],
    targets: [
        .target(
            name: "RegexReplacer",
            dependencies: []
        ),
        .target(
            name: "FoundationExtensions",
            dependencies: []
        ),
        .target(
            name: "LocalizationConverter",
            dependencies: [
                .target(name: "RegexReplacer"),
                .target(name: "FoundationExtensions")
            ]
        ),
        .target(
            name: "l10nconverter",
            dependencies: [
                .target(name: "LocalizationConverter"),
                "Commander"
            ]
        ),
        .testTarget(
            name: "LocalizationConverterTests",
            dependencies: ["LocalizationConverter"]
        ),
    ]
)
