//
//  LocalizableParserTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class LocalizableParserTests: XCTestCase {

    func test_parseString_emptyString() {
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: "")

        XCTAssertEqual(LocalizationMap(format: .ios), parsedResult)
    }

    func test_parseString_oneItem() {
        let testString = "\"localization_key\" = \"localized_value\";"
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: testString)

        XCTAssertEqual(
            LocalizationMap(format: .ios, dictionary: [
                "localization_key": "localized_value"
            ]),
            parsedResult)
    }

    func test_parseString_oneItem_unquotedKey() {
        let testString = "localization_key = \"localized_value\";"
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: testString)

        XCTAssertEqual(
            LocalizationMap(format: .ios, dictionary: [
                "localization_key": "localized_value"
            ]),
            parsedResult)
    }

    func test_parseString_twoItems() {
        let testString =
            "localization_key0 = \"localized_value0\";\n" +
            "localization_key1 = \"localized_value1\";"
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: testString)

        XCTAssertEqual(
            LocalizationMap(format: .ios, dictionary: [
                "localization_key0": "localized_value0",
                "localization_key1": "localized_value1"]),
            parsedResult)
    }

    func test_parseString_ignoreComments() {
        let testString =
            "localization_key0 = \"localized_value0\";\n" +
            "/* this is a comment */\n" +
            "localization_key1 = \"localized_value1\";"
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: testString)

        XCTAssertEqual(
            LocalizationMap(format: .ios, dictionary: [
                "localization_key0": "localized_value0",
                "localization_key1": "localized_value1"]),
            parsedResult)
    }

    func test_parseString_ignoreBlankLine() {
        let testString =
            "localization_key0 = \"localized_value0\";" +
            "\n" +
            "\nlocalization_key1 = \"localized_value1\";"
        let parser = LocalizableParser()

        let parsedResult = parser.parse(string: testString)

        XCTAssertEqual(
            LocalizationMap(format: .ios, dictionary: [
                "localization_key0": "localized_value0",
                "localization_key1": "localized_value1"]),
            parsedResult)
    }

}
