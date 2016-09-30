//
//  StringFileContentProviderTests.swift
//
//  Created by Sébastien Duperron on 30/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class StringFileContentProviderTests: XCTestCase {

    func test_That_store_ReturnsTheCorrectStoreForAGivenLanguage() throws {
        // GIVEN: a file content provider
        let stringData = "My string data"
        let encoding: String.Encoding = .utf16
        let data = stringData.data(using: encoding)!
        let fileProvider = FileContentProviderStub(data: data)
        let stringFileContentProvider = StringFileContentProvider(filePath: "myPath", encoding: encoding, provider: fileProvider)

        // WHEN: we retrieve the content
        let content = try stringFileContentProvider.content()

        // THEN: we have received the expected content
        XCTAssertEqual(stringData, content)
    }

    fileprivate struct FileContentProviderStub: FileContentProvider {
        let data: Data

        func contents(atPath path: String) -> Data? {
            return data
        }
    }

}
