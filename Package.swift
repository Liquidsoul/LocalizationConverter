// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "LocalizationConverter",
    products: [
        .executable(name: "l10nconverter", targets: ["l10nconverter"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.6.0")
    ],
    targets: [
        .target(name: "RegexReplacer"),
        .target(name: "FoundationExtensions"),
        .target(name: "LocalizationConverter", dependencies: [
            "RegexReplacer",
            "FoundationExtensions"
        ]),
        .target(name: "l10nconverter", dependencies: [
            "LocalizationConverter",
            "Commander"
        ]),
        .testTarget(name: "LocalizationConverterTests", dependencies: [
            "LocalizationConverter",
        ])
    ]
)
