import PackageDescription

let package = Package(
    name: "LocalizationConverter"
)

let targetRegexReplacer = Target(name: "RegexReplacer")
let targetFoundationExtensions = Target(name: "FoundationExtensions")
let targetLocalizationConverter = Target(name: "LocalizationConverter")
let targetL10nConverter = Target(name: "l10nconverter")

package.targets.append(targetRegexReplacer)
package.targets.append(targetFoundationExtensions)
package.targets.append(targetLocalizationConverter)
package.targets.append(targetL10nConverter)

package.targets = [
    Target(name: "LocalizationConverter", dependencies: [
        .Target(name: "RegexReplacer"),
        .Target(name: "FoundationExtensions")
    ]),
    Target(name: "l10nconverter", dependencies: [
        .Target(name: "LocalizationConverter")
    ])
]

package.dependencies = [
    Package.Dependency.Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0)
]
