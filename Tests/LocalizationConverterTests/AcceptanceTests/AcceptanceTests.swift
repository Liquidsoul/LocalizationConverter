//
//  AcceptanceTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class AcceptanceTests: XCTestCase {

    var tempDirectoryPath: String = "Not initialized!"

    override func setUp() {
        super.setUp()

        tempDirectoryPath = createTempDirectory()
    }

    override func tearDown() {
        deleteTempDirectory()

        super.tearDown()
    }

    func test_AndroidToiOSFileSuccessfulConversion() throws {
        // GIVEN: a strings.xml android file
        let sourceAndroidFilePath = try filePath("android/values/strings.xml")
        // GIVEN: output Localizable iOS files
        let outputStringsFilePath = tempDirectoryPath.appending(pathComponent: "Localizable.strings")
        let outputStringsDictFilePath = tempDirectoryPath.appending(pathComponent: "Localizable.stringsdict")
        // GIVEN: expected Localizable iOS files
        let expectedOutputStringsFilePath = try filePath("ios/Base.lproj/Localizable.strings")
        let expectedOutputStringsDictFilePath = try filePath("ios/Base.lproj/Localizable.stringsdict")

        // WHEN: we execute the converter
        let returnedValue = runConverter(with: [
            "\(self)",
            "convertAndroidFile",
            sourceAndroidFilePath,
            "--output=\(tempDirectoryPath)"
            ])

        // THEN: the execution was successful
        XCTAssertEqual(0, returnedValue)
        // THEN: contents of the output files match the expected contents
        XCTAssertTrue(compareFiles(expectedOutputStringsFilePath, testedFilePath: outputStringsFilePath))
        XCTAssertTrue(compareFiles(expectedOutputStringsDictFilePath, testedFilePath: outputStringsDictFilePath))
    }

    func test_AndroidToiOS_FolderConversion() throws {
        // GIVEN: a android resource folder
        let sourceAndroidFolderPath = try filePath("android/")
        // GIVEN: output iOS folder
        let outputFolderPath = tempDirectoryPath
        // GIVEN: expected iOS folder content
        let expectedOutputFolderContent = try filePath("ios/")

        // WHEN: we execute the converter
        let returnedValue = runConverter(with: [
            "\(self)",
            "convertAndroidFolder",
            sourceAndroidFolderPath,
            "--output=\(outputFolderPath)"
            ])

        // THEN: the execution was successful
        XCTAssertEqual(0, returnedValue)
        // THEN: contents of the output folder match the expected one
        XCTAssertTrue(compareFolders(expectedOutputFolderContent, testedFolderPath: outputFolderPath))
    }

    func test_AndroidToiOS_FolderConversion_includingPlurals() throws {
        // GIVEN: a android resource folder
        let sourceAndroidFolderPath = try filePath("android/")
        // GIVEN: output iOS folder
        let outputFolderPath = tempDirectoryPath
        // GIVEN: expected iOS folder content
        let expectedOutputFolderContent = try filePath("ios-plurals/")

        // WHEN: we execute the converter
        let returnedValue = runConverter(with: [
            "\(self)",
            "convertAndroidFolder",
            sourceAndroidFolderPath,
            "--output=\(outputFolderPath)",
            "--include-plurals"
            ])

        // THEN: the execution was successful
        XCTAssertEqual(0, returnedValue)
        // THEN: contents of the output folder match the expected one
        XCTAssertTrue(compareFolders(expectedOutputFolderContent, testedFolderPath: outputFolderPath))
    }
}

// MARK: - Test helper methods

extension AcceptanceTests {
    func filePath(_ partialPath: String) throws -> String {
        do {
            return try bundleFilePath(partialPath)
        } catch Error.fileNotFoundInBundle {
            return try localFilePath(partialPath)
        }
    }

    private func bundleFilePath(_ partialPath: String) throws -> String {
        let testBundle = Bundle(for: type(of: self))
        let testStubsFolderName = "testFiles"
        let path = testBundle.path(forResource: testStubsFolderName, ofType: nil, inDirectory: nil)
        guard let folderPath = path else {
            throw Error.fileNotFoundInBundle(path: testStubsFolderName)
        }
        let filePath = folderPath.appending(pathComponent: partialPath)
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: filePath) {
            throw Error.fileNotFound(path: filePath)
        }
        return filePath
    }

    private func localFilePath(_ partialPath: String) throws -> String {
        let fileManager = FileManager()
        let currentDirectoryPath = fileManager.currentDirectoryPath as NSString
        let testFilesDirectoryPath = currentDirectoryPath.appendingPathComponent("Tests/LocalizationConverterTests/AcceptanceTests/testFiles")
        guard fileManager.fileExists(atPath: testFilesDirectoryPath) else {
            throw Error.fileNotFound(path: testFilesDirectoryPath)
        }
        let filePath = (testFilesDirectoryPath as NSString).appendingPathComponent(partialPath)
        guard fileManager.fileExists(atPath: filePath) else {
            throw Error.fileNotFound(path: filePath)
        }
        return filePath
    }

    private enum Error: Swift.Error {
        case fileNotFoundInBundle(path: String)
        case fileNotFound(path: String)
    }

    func compareFiles(_ referenceFilePath: String, testedFilePath: String) -> Bool {
        return FileManager().contentsEqual(atPath: referenceFilePath, andPath: testedFilePath)
    }

    func compareFolders(_ referenceFolderPath: String, testedFolderPath: String) -> Bool {
        let fileManager = FileManager()

        do {
            let referenceSubPaths = try fileManager.subpathsOfDirectory(atPath: referenceFolderPath).sorted()
            let testedSubPaths = try fileManager.subpathsOfDirectory(atPath: testedFolderPath).sorted()
            guard referenceSubPaths == testedSubPaths else {
                print("Expected paths: \(referenceSubPaths), Got: \(testedSubPaths)")
                return false
            }
            return referenceSubPaths.reduce(true, { (result, subpath) -> Bool in
                if !result { return result }
                return result && compareFiles(
                    referenceFolderPath.appending(pathComponent: subpath),
                    testedFilePath: testedFolderPath.appending(pathComponent: subpath))
            })
        } catch {
            print("Failed to list subpaths with error: \(error)")
        }

        return false
    }
}

// MARK: - Environment setup and tear down functions

extension AcceptanceTests {

    func createTempDirectory() -> String {
        let fileManager = FileManager()
        do {
            let tempDirectoryURL = try self.tempDirectoryURL(using: fileManager)
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            return tempDirectoryURL.path
        } catch {
            fatalError("Could not create temp directory for tests")
        }
    }

    func tempDirectoryURL(using fileManager: FileManager) throws -> URL {
        let documentsDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .allDomainsMask,
            appropriateFor: nil,
            create: true)
        let tempDirectoryURL = documentsDirectory.appendingPathComponent("testResults")
        #if swift(>=2.3)
        return tempDirectoryURL
        #else
        return tempDirectoryURL
        #endif
    }

    func deleteTempDirectory() {
        do {
            try FileManager().removeItem(atPath: tempDirectoryPath)
        } catch {
            fatalError("Could not remove temp directory used in tests")
        }
    }

}
