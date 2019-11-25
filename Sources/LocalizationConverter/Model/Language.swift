//
//  Language.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

enum Language {
    case base
    case named(String)
}

extension Language: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .base:
                hasher.combine("base")
                break
            case .named(let name):
                hasher.combine("named.\(name)")
                break
        }
    }

    static func == (lhs: Language, rhs: Language) -> Bool {
        switch (lhs, rhs) {
        case (.base, .base): return true
        case let (.named(lhsName), .named(rhsName)): return lhsName == rhsName
        default: return false
        }
    }
}
