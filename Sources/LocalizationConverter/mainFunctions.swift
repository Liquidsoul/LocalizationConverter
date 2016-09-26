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

protocol LocalizationStore {
    func storeFormattedLocalizable(data: Data) throws
    func storeFormattedStringsDict(data: Data) throws
}

struct FileLocalizationStore: LocalizationStore {
    private let outputFolderPath: String
    private let localizablePath: String
    private let stringsDictPath: String

    init(outputFolderPath: String) {
        self.outputFolderPath = outputFolderPath
        localizablePath = outputFolderPath.appending(pathComponent: "Localizable.strings")
        stringsDictPath = outputFolderPath.appending(pathComponent: "Localizable.stringsdict")
    }

    func storeFormattedLocalizable(data: Data) throws {
        try createFolderHierarchyIfNecessary()
        try write(data: data, toFilePath: localizablePath)
    }

    func storeFormattedStringsDict(data: Data) throws {
        try createFolderHierarchyIfNecessary()
        try write(data: data, toFilePath: stringsDictPath)
    }

    private func createFolderHierarchyIfNecessary() throws {
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: outputFolderPath) { return }
        try fileManager.createDirectory(atPath: outputFolderPath, withIntermediateDirectories: true)
    }

    private func write(data: Data, toFilePath filePath: String) throws {
        guard FileManager().createFile(atPath: filePath, contents: data, attributes: nil) else {
            throw Error.fileWriteError(path: filePath)
        }
    }

    enum Error: Swift.Error {
        case fileWriteError(path: String)
    }
}

protocol StringContentProvider {
    func content() throws -> String
}

struct StringFileContentProvider: StringContentProvider {
    let filePath: String
    let encoding: String.Encoding

    init(filePath: String, encoding: String.Encoding = .utf16) {
        self.filePath = filePath
        self.encoding = encoding
    }

    func content() throws -> String {
        return try readFile(atPath: filePath, encoding: encoding)
    }

    private func readFile(atPath path: String, encoding: String.Encoding) throws -> String {
        let fileManager = FileManager()
        guard let content = fileManager.contents(atPath: path) else {
            throw Error.fileNotFound(path: path)
        }
        guard let contentAsString = String(data: content, encoding: encoding) else {
            throw Error.invalidFileContent(path: path, data: content)
        }
        return contentAsString
    }

    enum Error: Swift.Error {
        case fileNotFound(path: String)
        case invalidFileContent(path: String, data: Data)
    }
}

struct SingleItemConverter {
    let provider: StringContentProvider
    let store: LocalizationStore
    let includePlurals: Bool

    func execute() throws {
        do {
            let androidLocalizationString = try provider.content()
            let localization = try AndroidStringsParser().parse(string: androidLocalizationString)
            let localizableString = try LocalizableFormatter(includePlurals: includePlurals).format(localization)
            try store.storeFormattedLocalizable(data: localizableString)
            let stringsDictContent = try StringsDictFormatter().format(localization)
            try store.storeFormattedStringsDict(data: stringsDictContent)
        } catch StringsDictFormatter.Error.noPlurals {
            print("No plural found, skipping stringsdict file.")
        }
    }
}

public func convert(androidFileName fileName: String, outputPath: String, includePlurals: Bool) -> Bool {
    let stringsFileProvider: StringContentProvider = StringFileContentProvider(filePath: fileName, encoding: .utf8)
    let store: LocalizationStore = FileLocalizationStore(outputFolderPath: outputPath)

    let converter = SingleItemConverter(provider: stringsFileProvider, store: store, includePlurals: includePlurals)

    do {
        try converter.execute()
    } catch {
        print("Error: \(error)")
        return false
    }

    return true
}

public func convert(androidFolder resourceFolder: String, outputPath: String, includePlurals: Bool) -> Bool {
    let fileManager = FileManager()

    let outputFolder = outputPath

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
