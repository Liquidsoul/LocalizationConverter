//
//  CLIArgumentsParser.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

class CLIArgumentsParser {
    func parseAction(from arguments: [String]) throws -> CLIAction {
        if arguments.count == 0 {
            throw Error.noAction
        }
        let actionName = arguments[0]

        let parsedArguments = try Array(arguments[1..<arguments.count]).map(CLIArgument.init)
        let (anonymousArguments, namedArguments) = CLIArgument.decompose(arguments: parsedArguments)
        return try CLIAction(actionName: actionName, anonymousArguments: anonymousArguments, namedArguments: namedArguments)
    }

    enum Error: ErrorType {
        case noAction
    }
}
