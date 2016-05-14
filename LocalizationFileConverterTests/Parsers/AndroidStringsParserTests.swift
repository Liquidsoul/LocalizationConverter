//
//  AndroidStringsParserTests.swift
//  LocalizationFileConverter
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

class AndroidStringsParserTests: XCTestCase {

    func test_parseString_emptyString() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "")

        XCTAssertEqual(LocalizationMap(type: .android), parsedResult)
    }

    func test_parseString_stringItem() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<resources>\r\n<string name=\"localization_key\">localized_value</string>\r\n</resources>")

        XCTAssertEqual(LocalizationMap(type: .android, dictionary: ["localization_key": "localized_value"]), parsedResult)
    }

    func test_parseString_stringItemWithSpecialCharacter() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<resources>\r\n<string name=\"all.loading\">Loading…</string>\r\n</resources>")

        XCTAssertEqual(LocalizationMap(type: .android, dictionary: [
            "all.loading": "Loading…"
            ]), parsedResult)
    }

    func test_parseString_pluralItem() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<resources>\r\n<plurals name=\"localization_key\">\r\n<item quantity=\"zero\">zero_value</item>\r\n<item quantity=\"other\">other_value</item>\r\n</plurals>\r\n</resources>")

        XCTAssertEqual(LocalizationMap(type: .android, localizationsDictionary: ["localization_key": .plurals(values: [.zero: "zero_value", .other: "other_value"])]), parsedResult)
    }

    func test_parseString_pluralItemWithSpecialCharacter() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<resources>\r\n<plurals name=\"all.loading\">\r\n<item quantity=\"zero\">Loading none…</item>\r\n<item quantity=\"other\">Loading %d…</item>\r\n</plurals>\r\n</resources>")

        XCTAssertEqual(LocalizationMap(type: .android, localizationsDictionary: [
            "all.loading": .plurals(values: [
                .zero: "Loading none…",
                .other: "Loading %d…"
            ])
        ]), parsedResult)
    }

    func test_parseString_twoStringItem() {
        let parser = AndroidStringsParser()

        let parsedResult = parser.parse(string: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<resources>\r\n<string name=\"localization_key0\">localized_value0</string>\r\n<string name=\"localization_key1\">localized_value1</string>\r\n</resources>")

        XCTAssertEqual(LocalizationMap(type: .android, dictionary: [
            "localization_key0": "localized_value0",
            "localization_key1": "localized_value1"
            ]), parsedResult)
    }

}
