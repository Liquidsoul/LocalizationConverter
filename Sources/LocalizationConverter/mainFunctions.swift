//
//  mainFunctions.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
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

struct SingleItemConverter {
    let provider: LocalizationProvider
    let store: LocalizationStore
    let includePlurals: Bool

    func execute() throws {
        do {
            let localization = try provider.localization()
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
    let provider = AndroidLocalizationFileProvider(filePath: fileName)
    let store: LocalizationStore = FileLocalizationStore(outputFolderPath: outputPath)

    let converter = SingleItemConverter(provider: provider, store: store, includePlurals: includePlurals)

    do {
        try converter.execute()
    } catch {
        print("Error: \(error)")
        return false
    }

    return true
}

public func convert(androidFolder resourceFolder: String, outputPath: String, includePlurals: Bool) -> Bool {
    do {
        let l10nLanguageProvider = try AndroidLocalizationFolderStringProvider(folderPath: resourceFolder)
        let l10nLanguageStore = iOSLocalizationLanguageFolderStore(folderPath: outputPath)
        let converter = LocalizationLanguageConverter(provider: l10nLanguageProvider, store: l10nLanguageStore, includePlurals: includePlurals)
        try converter.execute()

        return true
    } catch {
        print("Error: \(error)")
        return false
    }
}
