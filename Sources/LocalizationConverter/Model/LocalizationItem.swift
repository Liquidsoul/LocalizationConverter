//
//  LocalizationItem.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

enum PluralType: String {
    case zero
    case one
    case two
    case few
    case many
    case other
}

enum LocalizationItem {
    case string(value: String)
    case plurals(values: [PluralType: String])
}

extension LocalizationItem: Equatable {}

func == (left: LocalizationItem, right: LocalizationItem) -> Bool {
    switch (left, right) {
    case let (.string(leftValue), .string(rightValue)):
        return leftValue == rightValue
    case let (.plurals(leftValues), .plurals(rightValues)):
        return leftValues == rightValues
    default:
        return false
    }
}

extension LocalizationItem: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .string(let value):
            return value
        case .plurals(let values):
            return values.keys
                .map({ $0.rawValue })
                .sorted()
                .map({ "\($0):\(values[PluralType(rawValue: $0)!]!)" })
                .joined(separator: "|")
        }
    }
}
