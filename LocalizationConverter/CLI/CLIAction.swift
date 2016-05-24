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
    case help
    case convertAndroidFile(androidFileName: String, outputPath: String?)
    case convertAndroidFolder(androidResourceFolder: String, outputPath: String?)
}

extension CLIAction: Equatable {}

func == (lhs: CLIAction, rhs: CLIAction) -> Bool {
    switch(lhs, rhs) {
    case (.help, .help):
        return true
    case let (
        .convertAndroidFile(androidFileName: leftAndroidFileName, outputPath: leftOutputPath),
        .convertAndroidFile(androidFileName: rightAndroidFileName, outputPath: rightOutputPath)
        ):
        return leftAndroidFileName == rightAndroidFileName
            && leftOutputPath == rightOutputPath
    case let (
        .convertAndroidFolder(androidResourceFolder: leftFolder, outputPath: leftOutputPath),
        .convertAndroidFolder(androidResourceFolder: rightFolder, outputPath: rightOutputPath)
        ):
        return leftFolder == rightFolder
            && leftOutputPath == rightOutputPath
    default:
        return false
    }
}

extension CLIAction {
    init(actionName name: String, anonymousArguments: [String], namedArguments: [String:String]) throws {
        switch name {
        case "help":
            self = .help
        case "convertAndroidFile":
            guard let androidFileName = anonymousArguments.first else {
                throw Error.missingArgument(actionName: name, missingArgument: "source android filename")
            }
            self = .convertAndroidFile(androidFileName: androidFileName, outputPath: namedArguments["output"])
        case "convertAndroidFolder":
            guard let androidResourceFolder = anonymousArguments.first else {
                throw Error.missingArgument(actionName: name, missingArgument: "source android folder")
            }
            self = .convertAndroidFolder(androidResourceFolder: androidResourceFolder, outputPath: namedArguments["output"])
        default:
            throw Error.unknownAction(actionName: name)
        }
    }

    enum Error: ErrorType {
        case unknownAction(actionName: String)
        case missingArgument(actionName: String, missingArgument: String)
    }
}
