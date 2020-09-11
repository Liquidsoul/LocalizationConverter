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
    func hash(into hasher: inout Hasher) {
        switch self {
        case .base:
            hasher.combine("base")
        case .named(let name): return
            hasher.combine("named.\(name)")
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
