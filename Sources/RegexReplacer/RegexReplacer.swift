//
//  RegexReplacer.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

public struct RegexReplacer {
    public init?(pattern: String, replaceTemplate: String, options: NSRegularExpression.Options = .caseInsensitive) {
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return nil
        }
        self.replaceTemplate = replaceTemplate
    }

    public func replacingMatches(in string: String) -> String {
        return regex.stringByReplacingMatches(
            in: string,
            options: NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSRange(location: 0, length: string.count),
            withTemplate: replaceTemplate)
    }

    fileprivate let regex: NSRegularExpression
    fileprivate let replaceTemplate: String
}
