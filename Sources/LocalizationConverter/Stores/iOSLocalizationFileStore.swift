//
//  iOSLocalizationFileStore.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import FoundationExtensions

protocol FileSystemWriter {
    func fileExists(atPath path: String) -> Bool
    func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]?) -> Bool
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : Any]?) throws
}

extension FileManager: FileSystemWriter {}

struct iOSLocalizationFileStore {
    private let fileSystemWriter: FileSystemWriter
    private let outputFolderPath: String
    private let localizablePath: String
    private let stringsDictPath: String
    fileprivate let includePlurals: Bool

    init(outputFolderPath: String, includePlurals: Bool, fileSystemWriter: FileSystemWriter = FileManager()) {
        self.outputFolderPath = outputFolderPath
        self.includePlurals = includePlurals
        localizablePath = outputFolderPath.appending(pathComponent: "Localizable.strings")
        stringsDictPath = outputFolderPath.appending(pathComponent: "Localizable.stringsdict")
        self.fileSystemWriter = fileSystemWriter
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
        if fileSystemWriter.fileExists(atPath: outputFolderPath) { return }
        try fileSystemWriter.createDirectory(atPath: outputFolderPath, withIntermediateDirectories: true, attributes: nil)
    }

    private func write(data: Data, toFilePath filePath: String) throws {
        guard fileSystemWriter.createFile(atPath: filePath, contents: data, attributes: nil) else {
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
