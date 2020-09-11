//
//  LocalizableParser.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class LocalizableParser: LocalizationParser {
    func parse(string: String) -> LocalizationMap {
        return string
            .split { $0 == "\n" }
            .reduce(LocalizationMap(format: .ios), { (localizationDict, keyValueCharView) -> LocalizationMap in
                var outputDict = localizationDict
                let trimCharacterSet = CharacterSet(charactersIn: " \n\";")
                let array = keyValueCharView
                    .split { $0 == "="}
                    .map { String.init($0).trimmingCharacters(in: trimCharacterSet) }
                if array.count == 2 {
                    outputDict[array[0]] = .string(value: array[1])
                }
                return outputDict
            })
    }
}
