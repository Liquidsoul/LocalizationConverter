//
//  StringsDictFormatter.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

struct StringsDictFormatter {
    func format(localization: LocalizationMap) throws -> NSData {
        let stringsDict = try self.stringsDict(fromLocalization: localization)

        return try NSPropertyListSerialization.dataWithPropertyList(stringsDict, format: .XMLFormat_v1_0, options: 0)
    }

    func stringsDict(fromLocalization localization: LocalizationMap) throws -> NSDictionary {
        let localizations = localization.convertedLocalization(.ios).localizations
        let pluralLocalizations = filterOnlyPluralLocalizations(localizations)
        if pluralLocalizations.count == 0 {
            throw Error.NoPlurals
        }

        let stringsDict = NSMutableDictionary()
        try pluralLocalizations.forEach { (key, values) in
            guard let _ = values[.other] else {
                throw Error.MissingOtherKey
            }
            stringsDict[key] = stringsDictValue(withValues: values)
        }

        return stringsDict
    }

    private func filterOnlyPluralLocalizations(localization: [String:LocalizationItem]) -> [String:[PluralType: String]] {
        if localization.count == 0 {
            return [:]
        }

        var pluralLocalizations = [String:[PluralType: String]]()
        localization.forEach { (key, value) in
            switch value {
            case .string:
                break
            case .plurals(let values):
                pluralLocalizations[key] = values
            }
        }
        return pluralLocalizations
    }

    private func stringsDictValue(withValues values: [PluralType: String]) -> [String:AnyObject] {
        let initialValues = [
            "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
            "NSStringFormatValueTypeKey": "d"
        ]
        return [
            "NSStringLocalizedFormatKey":"%#@elements@",
            "elements": values.reduce(initialValues, combine: { (elements, pair) -> [String:AnyObject] in
                var outputValues = elements
                outputValues[pair.0.rawValue] = pair.1
                return outputValues
            })
        ]
    }

    enum Error: ErrorType {
        case NoPlurals
        case MissingOtherKey
    }
}
