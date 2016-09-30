//
//  SingleItemConverterTests.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class SingleItemConverterTests: XCTestCase {

    func test_execute() throws {
        // GIVEN: some mock provider and store objects
        let provider = LocalizationProviderMock(type: .android, dictionary: ["l10nKey":"LocalizedString"])
        let store = LocalizationStoreMock()
        // GIVEN: a converter using these objects
        let converter = SingleItemConverter(provider: provider, store: store)

        // WHEN: we execute the converter routine
        try converter.execute()

        // THEN: provider and store objects were called
        XCTAssertTrue(provider.wasCalled)
        XCTAssertTrue(store.wasCalled)
        // THEN: the localization is of the expected type
        XCTAssertEqual(LocalizationType.android, store.localization?.type)
        // THEN: the localization has the expected content
        XCTAssertEqual(1, store.localization?.count)
        let item = store.localization?["l10nKey"]
        XCTAssertNotNil(item)
        if let item = item {
            XCTAssertEqual("LocalizedString", item.debugDescription)
        }
    }

    private class LocalizationProviderMock: LocalizationProvider {
        var wasCalled = false
        let type: LocalizationType
        let dictionary: [String:String]

        init(type: LocalizationType, dictionary: [String:String]) {
            self.type = type
            self.dictionary = dictionary
        }

        func localization() throws -> LocalizationMap {
            wasCalled = true
            return LocalizationMap(type: type, dictionary: dictionary)
        }
    }

    private class LocalizationStoreMock: LocalizationStore {
        var wasCalled = false
        var localization: LocalizationMap?

        func store(localization: LocalizationMap) throws {
            wasCalled = true
            self.localization = localization
        }
    }
}
