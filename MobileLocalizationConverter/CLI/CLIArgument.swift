//
//  CLIArgument.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

enum CLIArgument {
    case AnonymousValue(value: String)
    case NamedValue(name: String, value: String)
}

extension CLIArgument: Equatable {}

func == (lhs: CLIArgument, rhs: CLIArgument) -> Bool {
    switch (lhs, rhs) {
    case (let .AnonymousValue(value: lhsValue), let .AnonymousValue(value: rhsValue)):
        return lhsValue == rhsValue
    case (let .NamedValue(name: lhsName, value: lhsValue), let .NamedValue(name: rhsName, value: rhsValue)):
        return lhsValue == rhsValue && lhsName == rhsName
    default:
        return false
    }
}

extension CLIArgument {
    init(argument: String) throws {
        let trimCharacterSet = NSCharacterSet(charactersInString: " \"-")
        let components = argument.characters
            .split { $0 == "=" }
            .map { String.init($0).stringByTrimmingCharactersInSet(trimCharacterSet) }
        switch components.count {
        case 1:
            self = .AnonymousValue(value: components[0])
        case 2:
            self = .NamedValue(name: components[0], value: components[1])
        default:
            throw Error.UnparseableArgument(argument: argument)
        }
    }

    enum Error: ErrorType {
        case UnparseableArgument(argument: String)
    }
}

extension CLIArgument {
    static func decompose(argumentsArray argumentsArray: [CLIArgument]) -> ([String], [String:String]) {
        return argumentsArray.reduce(([], [:]), combine: { (decomposition, arg) -> ([String], [String:String]) in
            var decomposition = decomposition
            switch arg {
            case let .NamedValue(name: name, value: value):
                decomposition.1[name] = value
            case let .AnonymousValue(value: value):
                decomposition.0.append(value)
            }
            return decomposition
        })
    }
}
