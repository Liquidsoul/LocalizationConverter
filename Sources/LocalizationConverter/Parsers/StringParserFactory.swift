//
//  StringParserFactory.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class StringParserFactory {
    static func stringParser(from filename: String) -> StringParser {
        let nsFilename = filename as NSString
        switch nsFilename.pathExtension {
        case "xml":
            return AndroidStringsParser()
        case "strings":
            fallthrough
        default:
            return LocalizableParser()
        }
    }
}
