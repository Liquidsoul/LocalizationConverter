//
//  iOSLocalizationFileStoreTests.swift
//
//  Created by Sébastien Duperron on 30/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class iOSLocalizationFileStoreTests: XCTestCase {

    func test_That_store_StoreSimpleLocalizationItems() throws {
        // GIVEN: a fake writer
        let fsWriter = FileSystemWriterMock()
        // GIVEN: a localization
        let localization = LocalizationMap(format: .android, dictionary: ["key": "LocalizedValue"])
        // GIVEN: a store
        let store = iOSLocalizationFileStore(outputFolderPath: "outFolder", includePlurals: false, fileSystemWriter: fsWriter)

        // WHEN: we try to store the localization
        try store.store(localization: localization)

        // THEN: the file system received the expected modifications
        XCTAssertEqual(["createDirectory(atPath: outFolder)", "createFile(atPath: outFolder/Localizable.strings)"], fsWriter.commands)
    }

    func test_That_store_StoreSimpleAndPluralsLocalizationItems() throws {
        // GIVEN: a fake writer
        let fsWriter = FileSystemWriterMock(existingPaths: ["outFolder"])
        // GIVEN: a localization
        let pluralValue: LocalizationItem = .plurals(values: [.other: "PluralLocalizedValue"])
        let localization = LocalizationMap(format: .android, localizationsDictionary: ["pluralKey": pluralValue])
        // GIVEN: a store
        let store = iOSLocalizationFileStore(outputFolderPath: "outFolder", includePlurals: true, fileSystemWriter: fsWriter)

        // WHEN: we try to store the localization
        try store.store(localization: localization)

        // THEN: the file system received the expected modifications
        XCTAssertFalse(fsWriter.commands.contains("createDirectory(atPath: outFolder)"))
        XCTAssertTrue(fsWriter.commands.contains("createFile(atPath: outFolder/Localizable.strings)"))
        XCTAssertTrue(fsWriter.commands.contains("createFile(atPath: outFolder/Localizable.stringsdict)"))
    }

    func test_That_store_ThrowsAnErrorWhenFileSystemWriteFails() throws {
        // GIVEN: a fake writer
        let fsWriter = FailingFileSystemWriter()
        // GIVEN: a localization
        let localization = LocalizationMap(format: .android, dictionary: ["key": "LocalizedValue"])
        // GIVEN: a store
        let store = iOSLocalizationFileStore(outputFolderPath: "outFolder", includePlurals: false, fileSystemWriter: fsWriter)
        let callExpectation = expectation(description: "Thrown error")

        // WHEN: we try to store the localization
        do {
            try store.store(localization: localization)
        } catch iOSLocalizationFileStore.Error.fileWriteError(_) {
            // THEN: the error was thrown
            callExpectation.fulfill()
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    fileprivate class FileSystemWriterMock: FileSystemWriter {
        var commands = [String]()
        let existingPaths: [String]

        init(existingPaths: [String] = []) {
            self.existingPaths = existingPaths
        }

        func fileExists(atPath path: String) -> Bool {
            return existingPaths.contains(path)
        }

        func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]?) -> Bool {
            commands.append("createFile(atPath: \(path))")
            return true
        }

        func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : Any]?) throws {
            commands.append("createDirectory(atPath: \(path))")
        }
    }

    fileprivate struct FailingFileSystemWriter: FileSystemWriter {
        func fileExists(atPath path: String) -> Bool {
            return true
        }

        func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]?) -> Bool {
            return false
        }

        func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : Any]?) throws {
        }
    }
}
