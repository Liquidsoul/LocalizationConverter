//
//  LocalizableFormatter.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct LocalizableFormatter {
    let includePlurals: Bool

    init(includePlurals: Bool = true) {
        self.includePlurals = includePlurals
    }

    func format(localization: LocalizationMap) -> String {
        return format(localization.convertedLocalization(to: .ios).localizations)
    }

    private func format(localizations: [String:LocalizationItem]) -> String {
        var localizableEntries = [String]()

        localizations.forEach { (key, localizationItem) in
            switch localizationItem {
            case .string(let value):
                localizableEntries.append("\"\(key)\" = \"\(escapeDoubleQuotes(in: value))\";")
            case .plurals(let values):
                if includePlurals, let value = pluralValue(from: values) {
                    localizableEntries.append("\"\(key)\" = \"\(escapeDoubleQuotes(in: value))\";")
                }
            }
        }

        if localizableEntries.count == 0 { return "" }

        return localizableEntries.sort { $0.lowercaseString < $1.lowercaseString }.joinWithSeparator("\n") + "\n"
    }

    private func pluralValue(from values: [PluralType: String]) -> String? {
        let priorities: [PluralType] = [.other, .many, .few, .two, .one, .zero]
        return priorities.reduce(nil) { (value: String?, type) -> String? in
            if value != nil {
                return value
            }
            return values[type]
        }
    }

    private func escapeDoubleQuotes(in string: String) -> String {
        return string.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
    }
}
