//
//  mainFunctions.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import RegexReplacer
import FoundationExtensions

public func convert(androidFileName fileName: String, outputPath: String?, includePlurals: Bool) -> Bool {
    guard let localization = parseAndroidFile(withName: fileName) else {
        return false
    }

    let outputFolder = outputPath ?? FileManager().currentDirectoryPath
    let outputLocalizableStringsPath = outputFolder.appending(pathComponent: "Localizable.strings")
    let outputStringsDictPath = outputFolder.appending(pathComponent: "Localizable.stringsdict")

    let localizableString = LocalizableFormatter(includePlurals: includePlurals).format(localization)
    if !write(stringData: localizableString, toFilePath: outputLocalizableStringsPath) {
        print("Failed to write Localizable.strings file at path \(outputLocalizableStringsPath)")
        return false
    }
    do {
        let stringsDictContent = try StringsDictFormatter().format(localization)
        if !FileManager().createFile(atPath: outputStringsDictPath, contents: stringsDictContent, attributes: nil) {
            print("Failed to write stringsdict file at path \(outputStringsDictPath)")
            return false
        }
    } catch StringsDictFormatter.Error.noPlurals {
        print("No plural found, skipping stringsdict file.")
    } catch {
        print("Error when formatting stringsdict data \(error)")
        return false
    }

    return true
}

func parseAndroidFile(withName name: String) -> LocalizationMap? {
    guard let fileContent = readFile(withName: name, encoding: String.Encoding.utf8) else {
        return nil
    }
    return try? AndroidStringsParser().parse(string: fileContent)
}

func readFile(withName fileName: String, encoding: String.Encoding = String.Encoding.utf16) -> String? {
    let fileManager = FileManager()
    let filePath: String
    if fileManager.fileExists(atPath: fileName) {
        filePath = fileName
    } else {
        filePath = NSString.path(withComponents: [fileManager.currentDirectoryPath, fileName])
    }
    guard let content = fileManager.contents(atPath: filePath) else {
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
    if !FileManager().createFile(atPath: filePath, contents: string.data(using: String.Encoding.utf8), attributes: nil) {
        print("Failed to write output at path: \(filePath)")
        return false
    }
    return true
}

public func convert(androidFolder resourceFolder: String, outputPath: String?, includePlurals: Bool) -> Bool {
    let fileManager = FileManager()

    let outputFolder = outputPath ?? fileManager.currentDirectoryPath

    do {
        let folders = try fileManager.contentsOfDirectory(atPath: resourceFolder)
        let valuesFolders = folders.filter { (folderName) -> Bool in
            return folderName.hasPrefix("values")
        }

        let results = try valuesFolders.map { (valuesFolderName) -> Bool in
            guard let outputFolderName = iOSFolderName(from: valuesFolderName) else {
                print("Could not convert values folder name '\(valuesFolderName)' to its iOS counterpart")
                return false
            }
            let outputFolderPath = outputFolder.appending(pathComponent: outputFolderName)
            try fileManager.createDirectory(atPath: outputFolderPath, withIntermediateDirectories: true, attributes: nil)
            let inputFilePath = resourceFolder
                .appending(pathComponent: valuesFolderName)
                .appending(pathComponent: "strings.xml")
            return convert(androidFileName: inputFilePath, outputPath: outputFolderPath, includePlurals: includePlurals)
        }
        return results.reduce(true, { (accumulator, result) -> Bool in
            return accumulator && result
        })
    } catch {
        print("Error: \(error)")
        return false
    }
}

func iOSFolderName(from valuesName: String) -> String? {
    if valuesName == "values" { return "Base.lproj" }

    let replacer = RegexReplacer(pattern: "values-(.*)", replaceTemplate: "$1.lproj")
    return replacer?.replacingMatches(in: valuesName)
}
