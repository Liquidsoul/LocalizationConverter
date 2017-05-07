//
//  StringsDictFormatter.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

struct StringsDictFormatter {
    func format(_ localization: LocalizationMap) throws -> Data {
        let stringsDict = try self.stringsDict(from: localization)

        return try PropertyListSerialization.data(fromPropertyList: stringsDict, format: .xml, options: 0)
    }

    func stringsDict(from localization: LocalizationMap) throws -> NSDictionary {
        let localizations = localization.convertedLocalization(to: .ios).localizations
        let pluralLocalizations = plurals(from: localizations)
        if pluralLocalizations.count == 0 {
            throw Error.noPlurals
        }

        let stringsDict = NSMutableDictionary()
        try pluralLocalizations.forEach { (key, values) in
            guard values[.other] != nil else {
                throw Error.missingOtherKey
            }
            stringsDict[key] = stringsDictItem(with: values)
        }

        return stringsDict
    }

    fileprivate func plurals(from localizations: [String:LocalizationItem]) -> [String:[PluralType: String]] {
        if localizations.count == 0 {
            return [:]
        }

        var pluralLocalizations = [String: [PluralType: String]]()
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

    fileprivate func stringsDictItem(with values: [PluralType: String]) -> [String:Any] {
        let initialValues: [String:Any] = [
            "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
            "NSStringFormatValueTypeKey": "d"
        ]
        return [
            "NSStringLocalizedFormatKey": "%#@elements@",
            "elements": values.reduce(initialValues as [String:Any], { (elements, pair) -> [String:Any] in
                var outputValues = elements
                outputValues[pair.0.rawValue] = pair.1
                return outputValues
            })
        ]
    }

    enum Error: Swift.Error {
        case noPlurals
        case missingOtherKey
    }
}
