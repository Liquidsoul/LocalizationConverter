//
//  AcceptanceTests.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

class AcceptanceTests: XCTestCase {

    var tempDirectoryPath: String!

    override func setUp() {
        super.setUp()

        tempDirectoryPath = createTempDirectory()
    }

    override func tearDown() {
        deleteTempDirectory()

        super.tearDown()
    }

    func createTempDirectory() -> String {
        let fileManager = NSFileManager()
        do {
            let documentsDirectory = try fileManager.URLForDirectory(
                .CachesDirectory,
                inDomain: .AllDomainsMask,
                appropriateForURL: nil,
                create: true)
            let tempDirectoryURL = documentsDirectory.URLByAppendingPathComponent("testResults")
            try fileManager.createDirectoryAtURL(tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            guard let path = tempDirectoryURL.path else {
                fatalError("Could not get path from URL of temp directory \(tempDirectoryURL)")
            }
            return path
        } catch {
            fatalError("Could not create temp directory for tests")
        }
    }

    func deleteTempDirectory() {
        do {
            try NSFileManager().removeItemAtPath(tempDirectoryPath)
        } catch {
            fatalError("Could not remove temp directory used in tests")
        }
    }

    func test_AndroidToiOSFileSuccessfulConversion() {
        // GIVEN: a strings.xml android file
        let sourceAndroidFilePath = bundleFilePath("android/values/strings.xml")
        // GIVEN: output Localizable iOS files
        let nsTempDirectoryPath = (tempDirectoryPath as NSString)
        let outputStringsFilePath = nsTempDirectoryPath.stringByAppendingPathComponent("Localizable.strings")
        let outputStringsDictFilePath = nsTempDirectoryPath.stringByAppendingPathComponent("Localizable.stringsdict")
        // GIVEN: exepected Localizable iOS files
        let expectedOutputStringsFilePath = bundleFilePath("ios/Base.lproj/Localizable.strings")
        let expectedOutputStringsDictFilePath = bundleFilePath("ios/Base.lproj/Localizable.stringsdict")

        // WHEN: we execute the converter
        let returnedValue = runConverter(withArguments: [
            "\(self)",
            "convertLocalization",
            sourceAndroidFilePath,
            "--output=\(tempDirectoryPath)"
            ])

        // THEN: the execution was successful
        XCTAssertEqual(0, returnedValue)
        // THEN: contents of the output files match the expected contents
        XCTAssertTrue(compareFiles(expectedOutputStringsFilePath, testedFilePath: outputStringsFilePath))
        XCTAssertTrue(compareFiles(expectedOutputStringsDictFilePath, testedFilePath: outputStringsDictFilePath))
    }

    func bundleFilePath(partialPath: String) -> String {
        let testBundle = NSBundle(forClass: self.dynamicType)
        let testStubsFolderName = "testFiles"
        let path = testBundle.pathForResource(testStubsFolderName, ofType: nil, inDirectory: nil)
        guard let folderPath = path else {
            fatalError("Could not locate bundle folder '\(testStubsFolderName)'")
        }
        let filePath = (folderPath as NSString).stringByAppendingPathComponent(partialPath)
        let fileManager = NSFileManager()
        XCTAssertTrue(fileManager.fileExistsAtPath(filePath))
        return filePath
    }

    func compareFiles(referenceFilePath: String, testedFilePath: String) -> Bool {
        let fileManager = NSFileManager()

        guard let
            referenceData = fileManager.contentsAtPath(referenceFilePath),
            testedData = fileManager.contentsAtPath(testedFilePath)
            else {
                return false
        }

        return referenceData == testedData
    }

}
