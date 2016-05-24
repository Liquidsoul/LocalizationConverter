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
        let stringsDict = try self.stringsDict(from: localization)

        return try NSPropertyListSerialization.dataWithPropertyList(stringsDict, format: .XMLFormat_v1_0, options: 0)
    }

    func stringsDict(from localization: LocalizationMap) throws -> NSDictionary {
        let localizations = localization.convertedLocalization(to: .ios).localizations
        let pluralLocalizations = plurals(from: localizations)
        if pluralLocalizations.count == 0 {
            throw Error.noPlurals
        }

        let stringsDict = NSMutableDictionary()
        try pluralLocalizations.forEach { (key, values) in
            guard let _ = values[.other] else {
                throw Error.missingOtherKey
            }
            stringsDict[key] = stringsDictItem(with: values)
        }

        return stringsDict
    }

    private func plurals(from localizations: [String:LocalizationItem]) -> [String:[PluralType: String]] {
        if localizations.count == 0 {
            return [:]
        }

        var pluralLocalizations = [String:[PluralType: String]]()
        localizations.forEach { (key, value) in
            switch value {
            case .string:
                break
            case .plurals(let values):
                pluralLocalizations[key] = values
            }
        }
        return pluralLocalizations
    }

    private func stringsDictItem(with values: [PluralType: String]) -> [String:AnyObject] {
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
        case noPlurals
        case missingOtherKey
    }
}
