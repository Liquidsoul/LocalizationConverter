//
//  LocalizationLanguageConverterTests.swift
//
//  Created by Sébastien Duperron on 30/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class LocalizationLanguageConverterTests: XCTestCase {

    func test_execute() throws {
        // GIVEN: some mock provider and store objects
        let provider = LocalizationLanguageProviderMock(language: .base)
        let store = LocalizationLanguageStoreMock()
        // GIVEN: a converter using these objects
        let converter = LocalizationLanguageConverter(provider: provider, store: store)

        // WHEN: we execute the converter routine
        try converter.execute()

        // THEN: provider and store objects were called
        XCTAssertTrue(provider.wasCalled)
        XCTAssertTrue(store.wasCalled)
    }

    private class LocalizationLanguageProviderMock: LocalizationLanguageProvider {
        var wasCalled = false
        let language: Language

        init(language: Language) {
            self.language = language
        }

        var languages: [Language] { return [language] }

        func contentProvider(for language: Language) -> LocalizationProvider {
            wasCalled = (language == self.language)
            return LocalizationProviderMock()
        }

        private class LocalizationProviderMock: LocalizationProvider {
            func localization() throws -> LocalizationMap {
                return LocalizationMap(type: .android)
            }
        }
    }

    private class LocalizationLanguageStoreMock: LocalizationLanguageStore {
        var wasCalled = false
        var localization: LocalizationMap?

        func store(for language: Language) -> LocalizationStore {
            wasCalled = true
            return LocalizationStoreMock()
        }

        private class LocalizationStoreMock: LocalizationStore {
            func store(localization: LocalizationMap) throws {
            }
        }
    }
}
