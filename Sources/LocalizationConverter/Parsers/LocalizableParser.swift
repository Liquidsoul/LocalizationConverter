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
            .split(separator: "\n")
            .reduce(LocalizationMap(format: .ios), { (localizationMap, line) -> LocalizationMap in
                var outputMap = localizationMap
                let trimCharacterSet = CharacterSet(charactersIn: " \n\";")
                let array = line.split(separator: "=")
                    .map { $0.trimmingCharacters(in: trimCharacterSet)}
                if array.count == 2 {
                    outputMap[array[0]] = .string(value: array[1])
                }
                return outputMap
        })
    }
}
