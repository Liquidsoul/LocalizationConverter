//
//  iOSLocalizationFileStore.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import FoundationExtensions

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
