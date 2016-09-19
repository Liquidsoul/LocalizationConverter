//
//  CLIAction.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

enum CLIAction {
    case help
    case convertAndroidFile(androidFileName: String, outputPath: String?, includePlurals: Bool)
    case convertAndroidFolder(androidResourceFolder: String, outputPath: String?, includePlurals: Bool)
}

extension CLIAction: Equatable {}

func == (lhs: CLIAction, rhs: CLIAction) -> Bool {
    switch(lhs, rhs) {
    case (.help, .help):
        return true
    case let (
        .convertAndroidFile(leftAndroidFileName, leftOutputPath, leftIncludePlurals),
        .convertAndroidFile(rightAndroidFileName, rightOutputPath, rightIncludePlurals)
        ):
        return leftAndroidFileName == rightAndroidFileName
            && leftOutputPath == rightOutputPath
            && leftIncludePlurals == rightIncludePlurals
    case let (
        .convertAndroidFolder(leftFolder, leftOutputPath, leftIncludePlurals),
        .convertAndroidFolder(rightFolder, rightOutputPath, rightIncludePlurals)
        ):
        return leftFolder == rightFolder
            && leftOutputPath == rightOutputPath
            && leftIncludePlurals == rightIncludePlurals
    default:
        return false
    }
}

extension CLIAction {
    init(actionName name: String, anonymousArguments: [String], namedArguments: [String:String]) throws {
        let includePlurals = anonymousArguments.contains("include-plurals")
        switch name {
        case "help":
            self = .help
        case "convertAndroidFile":
            guard let androidFileName = anonymousArguments.first else {
                throw Error.missingArgument(actionName: name, missingArgument: "source android filename")
            }
            self = .convertAndroidFile(androidFileName: androidFileName,
                                       outputPath: namedArguments["output"],
                                       includePlurals: includePlurals)
        case "convertAndroidFolder":
            guard let androidResourceFolder = anonymousArguments.first else {
                throw Error.missingArgument(actionName: name, missingArgument: "source android folder")
            }
            self = .convertAndroidFolder(androidResourceFolder: androidResourceFolder,
                                         outputPath: namedArguments["output"],
                                         includePlurals: includePlurals)
        default:
            throw Error.unknownAction(actionName: name)
        }
    }

    enum Error: Swift.Error {
        case unknownAction(actionName: String)
        case missingArgument(actionName: String, missingArgument: String)
    }
}
