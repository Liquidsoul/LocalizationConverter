//
//  LocalizableParser.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class LocalizableParser: StringParser {
    func parse(string string: String) -> LocalizationMap {
        return string.characters
            .split { $0 == "\n" }
            .reduce(LocalizationMap(type: .ios), combine: { (localization_dict, keyValueCharView) -> LocalizationMap in
                var output_dict = localization_dict
                let trimCharacterSet = NSCharacterSet(charactersInString: " \n\";")
                let array = keyValueCharView
                    .split { $0 == "="}
                    .map { String.init($0).stringByTrimmingCharactersInSet(trimCharacterSet) }
                if array.count == 2 {
                    output_dict[array[0]] = .string(value: array[1])
                }
                return output_dict
            })
    }
}
