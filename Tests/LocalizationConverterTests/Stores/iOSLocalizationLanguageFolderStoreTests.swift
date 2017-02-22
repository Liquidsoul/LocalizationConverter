//
//  iOSLocalizationLanguageFolderStoreTests.swift
//
//  Created by Sébastien Duperron on 26/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

// Disable rule to allow iOS prefixed declarations
// swiftlint:disable type_name

import XCTest

@testable import LocalizationConverter

class iOSLocalizationLanguageFolderStoreTests: XCTestCase {

    func test_That_store_ReturnsTheCorrectStoreForAGivenLanguage() {
        // GIVEN: a language folder store
        let languageFolderStore = iOSLocalizationLanguageFolderStore(folderPath: "outFolder", includePlurals: false)

        // WHEN: we retrieve to store for the base language
        let store = languageFolderStore.store(for: .base)

        // THEN: we have received the expected store
        XCTAssertTrue(store is iOSLocalizationFileStore)
    }

}
