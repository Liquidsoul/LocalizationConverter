//
//  CLIAction.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

enum CLIAction {
    case Help
    case ConvertLocalization(androidFileName: String, outputPath: String?)
}

extension CLIAction: Equatable {}

func ==(lhs: CLIAction, rhs: CLIAction) -> Bool {
    switch(lhs, rhs) {
    case (.Help, .Help):
        return true
    case let (.ConvertLocalization(androidFileName: leftAndroidFileName, outputPath: leftOutputPath), .ConvertLocalization(androidFileName: rightAndroidFileName, outputPath: rightOutputPath)):
        return leftAndroidFileName == rightAndroidFileName
            && leftOutputPath == rightOutputPath
    default:
        return false
    }
}

extension CLIAction {
    init(actionName name: String, anonymousArguments: [String], namedArguments: [String:String]) throws {
        switch name {
        case "help":
            self = .Help
        case "convertLocalization":
            guard let androidFileName = anonymousArguments.first else {
                throw Error.MissingArgument(actionName: name, missingArgument: "source android filename")
            }
            self = .ConvertLocalization(androidFileName: androidFileName, outputPath: namedArguments["output"])
        default:
            throw Error.UnknownAction(actionName: name)
        }
    }

    enum Error: ErrorType {
        case UnknownAction(actionName: String)
        case MissingArgument(actionName: String, missingArgument: String)
    }
}
