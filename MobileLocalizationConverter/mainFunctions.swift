//
//  mainFunctions.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

func runConverter(withArguments arguments: [String]) -> Int32 {
    let parser = CLIArgumentsParser()

    let processAndArguments = arguments
    let processName = processAndArguments[0]
    let scriptArguments = Array(processAndArguments[1..<processAndArguments.count])

    do {
        let action = try parser.parseAction(arguments: scriptArguments)
        switch action {
        case .Help:
            printUsage(processName: processName)
            return 0
        case let .ConvertLocalization(androidFileName: androidFileName, outputPath: outputPath):
            return convertLocalization(androidFileName, outputPath: outputPath)
        }
    } catch let CLIAction.Error.MissingArgument(actionName: actionName, missingArgument: argumentName) {
        print("Missing argument '\(argumentName)' for action '\(actionName)'")
        return 1
    } catch CLIArgumentsParser.Error.NoAction {
        print("You must specify an action. Run 'help' action to print usage.")
        return 1
    } catch {
        print("Error \(error)")
        return 1
    }
}

func printUsage(processName processName: String) {
    print("Usage: \(processName) ACTION [OPTIONS]")
    print("")
    print("Actions:")
    print(" - help:")
    print("        print this help")
    print(" - convertLocalization:")
    print("        Read a given Android strings.xml file and generate the corresponding Localizable.strings and Localizable.stringsdict files for iOS.")
    print("        Options:")
    print("          <strings_xml_filename> : [mandatory] the source strings.xml file.")
    print("          --output=<filepath> : output folder where to write the result iOS files.")
}

func convertLocalization(androidFileName: String, outputPath: String?) -> Int32 {
    guard let localization = parseAndroidFile(withName: androidFileName) else {
        return 1
    }

    let outputFolder = outputPath ?? NSFileManager().currentDirectoryPath
    let outputLocalizableStringsPath = (outputFolder as NSString).stringByAppendingPathComponent("Localizable.strings")
    let outputStringsDictPath = (outputFolder as NSString).stringByAppendingPathComponent("Localizable.stringsdict")

    let localizableString = LocalizableFormatter().format(localization)
    if !write(stringData: localizableString, toFilePath: outputLocalizableStringsPath) {
        print("Failed to write Localizable.strings file at path \(outputLocalizableStringsPath)")
        return 1
    }
    do {
        let stringsDictContent = try StringsDictFormatter().format(localization)
        if !NSFileManager().createFileAtPath(outputStringsDictPath, contents: stringsDictContent, attributes: nil) {
            print("Failed to write stringsdict file at path \(outputStringsDictPath)")
            return 1
        }
    } catch StringsDictFormatter.Error.NoPlurals {
        print("No plural found, skipping stringsdict file.")
    } catch {
        print("Error when formatting stringsdict data \(error)")
        return 1
    }

    return 0
}

func parseAndroidFile(withName name: String) -> LocalizationMap? {
    guard let fileContent = readFile(withName: name, encoding: NSUTF8StringEncoding) else {
        return nil
    }
    return AndroidStringsParser().parse(string: fileContent)
}

func readFile(withName fileName: String, encoding: UInt = NSUTF16StringEncoding) -> String? {
    let fileManager = NSFileManager()
    let filePath: String
    if fileManager.fileExistsAtPath(fileName) {
        filePath = fileName
    } else {
        filePath = NSString.pathWithComponents([fileManager.currentDirectoryPath, fileName])
    }
    guard let content = fileManager.contentsAtPath(filePath) else {
        print("Failed to load file \(fileName) from path \(filePath)")
        return nil
    }
    guard let contentAsString = String(data: content, encoding: encoding) else {
        print("Failed to read contents of file at path \(filePath)")
        return nil
    }
    return contentAsString
}

func write(stringData string: String, toFilePath filePath: String) -> Bool {
    if !NSFileManager().createFileAtPath(filePath, contents: string.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil) {
        print("Failed to write output at path: \(filePath)")
        return false
    }
    return true
}
