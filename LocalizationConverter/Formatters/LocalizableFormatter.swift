//
//  LocalizableFormatter.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct LocalizableFormatter {
    func format(localization: LocalizationMap) -> String {
        return format(localization.convertedLocalization(to: .ios).localizations)
    }

    private func format(localizations: [String:LocalizationItem]) -> String {
        var localizableEntries = [String]()

        localizations.forEach { (key, localizationItem) in
            switch localizationItem {
            case .string(let value):
                localizableEntries.append("\"\(key)\" = \"\(escapeDoubleQuotes(in: value))\";")
            case .plurals:
                break
            }
        }

        if localizableEntries.count == 0 { return "" }

        return localizableEntries.sort { $0.lowercaseString < $1.lowercaseString }.joinWithSeparator("\n") + "\n"
    }

    private func escapeDoubleQuotes(in string: String) -> String {
        return string.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
    }
}
