//
//  AcceptanceTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

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

    func test_AndroidToiOSFileSuccessfulConversion() {
        // GIVEN: a strings.xml android file
        let sourceAndroidFilePath = bundleFilePath("android/values/strings.xml")
        // GIVEN: output Localizable iOS files
        let outputStringsFilePath = tempDirectoryPath.appending(pathComponent: "Localizable.strings")
        let outputStringsDictFilePath = tempDirectoryPath.appending(pathComponent: "Localizable.stringsdict")
        // GIVEN: expected Localizable iOS files
        let expectedOutputStringsFilePath = bundleFilePath("ios/Base.lproj/Localizable.strings")
        let expectedOutputStringsDictFilePath = bundleFilePath("ios/Base.lproj/Localizable.stringsdict")

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

    func test_AndroidToiOS_FolderConversion() {
        // GIVEN: a android resource folder
        let sourceAndroidFolderPath = bundleFilePath("android/")
        // GIVEN: output iOS folder
        let outputFolderPath = tempDirectoryPath
        // GIVEN: expected iOS folder content
        let expectedOutputFolderContent = bundleFilePath("ios/")

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

    func test_AndroidToiOS_FolderConversion_includingPlurals() {
        // GIVEN: a android resource folder
        let sourceAndroidFolderPath = bundleFilePath("android/")
        // GIVEN: output iOS folder
        let outputFolderPath = tempDirectoryPath
        // GIVEN: expected iOS folder content
        let expectedOutputFolderContent = bundleFilePath("ios-plurals/")

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

    func bundleFilePath(partialPath: String) -> String {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let testStubsFolderName = "testFiles"
        let path = testBundle.pathForResource(testStubsFolderName, ofType: nil, inDirectory: nil)
        guard let folderPath = path else {
            fatalError("Could not locate bundle folder '\(testStubsFolderName)'")
        }
        let filePath = folderPath.appending(pathComponent: partialPath)
        let fileManager = NSFileManager()
        XCTAssertTrue(fileManager.fileExistsAtPath(filePath))
        return filePath
    }

    func compareFiles(referenceFilePath: String, testedFilePath: String) -> Bool {
        return NSFileManager().contentsEqualAtPath(referenceFilePath, andPath: testedFilePath)
    }

    func compareFolders(referenceFolderPath: String, testedFolderPath: String) -> Bool {
        let fileManager = NSFileManager()

        do {
            let referenceSubPaths = try fileManager.subpathsOfDirectoryAtPath(referenceFolderPath).sort()
            let testedSubPaths = try fileManager.subpathsOfDirectoryAtPath(testedFolderPath).sort()
            guard referenceSubPaths == testedSubPaths else {
                print("Expected paths: \(referenceSubPaths), Got: \(testedSubPaths)")
                return false
            }
            return referenceSubPaths.reduce(true, combine: { (result, subpath) -> Bool in
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
        let fileManager = NSFileManager()
        do {
            let tempDirectoryURL = try self.tempDirectoryURL(using: fileManager)
            try fileManager.createDirectoryAtURL(tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            guard let path = tempDirectoryURL.path else {
                fatalError("Could not get path from URL of temp directory \(tempDirectoryURL)")
            }
            return path
        } catch {
            fatalError("Could not create temp directory for tests")
        }
    }

    func tempDirectoryURL(using fileManager: NSFileManager) throws -> NSURL {
        let documentsDirectory = try fileManager.URLForDirectory(
            .CachesDirectory,
            inDomain: .AllDomainsMask,
            appropriateForURL: nil,
            create: true)
        let tempDirectoryURL = documentsDirectory.URLByAppendingPathComponent("testResults")
        #if swift(>=2.3)
        return tempDirectoryURL!
        #else
        return tempDirectoryURL
        #endif
    }

    func deleteTempDirectory() {
        do {
            try NSFileManager().removeItemAtPath(tempDirectoryPath)
        } catch {
            fatalError("Could not remove temp directory used in tests")
        }
    }

}
