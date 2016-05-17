//
//  RegexReplacer.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

struct RegexReplacer {
    init?(pattern: String, replaceTemplate: String, options: NSRegularExpressionOptions = .CaseInsensitive) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return nil
        }
        self.replaceTemplate = replaceTemplate
    }

    func stringByReplacingMatchesInString(string: String) -> String {
        return regex.stringByReplacingMatchesInString(
            string,
            options: NSMatchingOptions(rawValue: 0),
            range: NSRange(location: 0, length: string.characters.count),
            withTemplate: replaceTemplate)
    }

    private let regex: NSRegularExpression
    private let replaceTemplate: String
}
