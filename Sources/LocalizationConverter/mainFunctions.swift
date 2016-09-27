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
    func store(localization: LocalizationMap) throws
}

struct iOSLocalizationFileStore {
    private let outputFolderPath: String
    private let localizablePath: String
    private let stringsDictPath: String
    fileprivate let includePlurals: Bool

    init(outputFolderPath: String, includePlurals: Bool) {
        self.outputFolderPath = outputFolderPath
        self.includePlurals = includePlurals
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

extension iOSLocalizationFileStore: LocalizationStore {
    func store(localization: LocalizationMap) throws {
        let localizableString = try LocalizableFormatter(includePlurals: includePlurals).format(localization)
        try storeFormattedLocalizable(data: localizableString)

        do {
            let stringsDictContent = try StringsDictFormatter().format(localization)
            try storeFormattedStringsDict(data: stringsDictContent)
        } catch StringsDictFormatter.Error.noPlurals {
            print("No plural found, skipping stringsdict file.")
        }
    }
}

struct SingleItemConverter {
    let provider: LocalizationProvider
    let store: LocalizationStore

    func execute() throws {
        let localization = try provider.localization()
        try store.store(localization: localization)
    }
}

public func convert(androidFileName fileName: String, outputPath: String, includePlurals: Bool) -> Bool {
    let provider = AndroidLocalizationFileProvider(filePath: fileName)
    let store = iOSLocalizationFileStore(outputFolderPath: outputPath, includePlurals: includePlurals)

    let converter = SingleItemConverter(provider: provider, store: store)

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
        let l10nLanguageStore = iOSLocalizationLanguageFolderStore(folderPath: outputPath, includePlurals: includePlurals)
        let converter = LocalizationLanguageConverter(provider: l10nLanguageProvider, store: l10nLanguageStore)
        try converter.execute()

        return true
    } catch {
        print("Error: \(error)")
        return false
    }
}
