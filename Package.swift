import PackageDescription

let package = Package(
    name: "LocalizationConverter"
)

let targetRegexReplacer = Target(name: "RegexReplacer")
let targetFoundationExtensions = Target(name: "FoundationExtensions")
let targetLocalizationConverter = Target(name: "LocalizationConverter")

package.targets.append(targetRegexReplacer)
package.targets.append(targetFoundationExtensions)
package.targets.append(targetLocalizationConverter)

package.targets = [
    Target(name: "LocalizationConverter", dependencies: [
        .Target(name: "RegexReplacer"),
        .Target(name: "FoundationExtensions")
    ])
]
