//
//  LocalizationMap.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

struct LocalizationMap {
    /**
     This describes the format used in the Localization strings.
     This is necessary because of the differences of content of string values like string parameters.
     `%s` is for Java string on Android while the equivalent is `%@` on iOS.
     */
    enum Format {
        case android
        case ios
    }

    fileprivate(set) var format: Format
    fileprivate(set) var localizations = [String:LocalizationItem]()

    init(format: Format) {
        self.format = format
    }

    init(format: Format, dictionary: [String:String]) {
        self.init(format: format)
        dictionary.forEach { localizations[$0] = .string(value: $1) }
    }

    init(format: Format, localizationsDictionary: [String:LocalizationItem]) {
        self.init(format: format)
        localizations = localizationsDictionary
    }

    subscript(key: String) -> LocalizationItem? {
        get {
            return localizations[key]
        }

        set(newValue) {
            guard let newValue = newValue else {
                localizations.removeValue(forKey: key)
                return
            }
            localizations[key] = newValue
        }
    }

    var keys: [String] {
        return Array(localizations.keys)
    }

    var count: Int {
        return localizations.count
    }
}

extension LocalizationMap: Equatable {
    static func == (left: LocalizationMap, right: LocalizationMap) -> Bool {
        return left.format == right.format
            && left.localizations == right.localizations
    }
}

import RegexReplacer

extension LocalizationMap {
    func convertedLocalization(to format: Format) -> LocalizationMap {
        let sourceFormat = self.format
        let destinationFormat = format

        switch (sourceFormat, destinationFormat) {
            case let (source, destination) where source == destination:
                return self
            case (.android, .ios):
                guard let stringParameterReplacer = RegexReplacer(pattern: "%([0-9]+\\$)?s", replaceTemplate: "%$1@") else {
                    fatalError("Could not initialize replacer!")
                }

                return LocalizationMap(
                    format: destinationFormat,
                    localizationsDictionary: convert(localizations, using: stringParameterReplacer))
            default:
               fatalError("Unsupported convertion \(sourceFormat) -> \(destinationFormat)")
        }
    }

    fileprivate func convert(_ localizations: [String:LocalizationItem],
                         using replacer: RegexReplacer) -> [String:LocalizationItem] {
        var iOSLocalizations = [String:LocalizationItem]()
        localizations.forEach { (key, item) in
            let convertedItem: LocalizationItem
            switch item {
            case .string(let value):
                convertedItem = .string(value: replacer.replacingMatches(in: value))
            case .plurals(let plurals):
                let convertedPlurals = convert(plurals, using: replacer)
                convertedItem = .plurals(values: convertedPlurals)
            }
            iOSLocalizations[key] = convertedItem
        }
        return iOSLocalizations
    }

    fileprivate func convert(_ plurals: [PluralType:String], using replacer: RegexReplacer) -> [PluralType:String] {
        var convertedPlurals = [PluralType:String]()
        plurals.forEach { (type, value) in
            convertedPlurals[type] = replacer.replacingMatches(in: value)
        }
        return convertedPlurals
    }
}
