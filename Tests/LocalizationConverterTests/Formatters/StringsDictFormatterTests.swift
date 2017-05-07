//
//  StringsDictFormatterTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class StringsDictFormatterTests: XCTestCase {

    func test_format_noLocalizationKeys() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(
            format: .android,
            localizationsDictionary: [:])

        let throwExpectaction = self.expectation(description: "Throw expectation")
        do {
            _ = try localizableFormatter.format(localization)
        } catch StringsDictFormatter.Error.noPlurals {
            throwExpectaction.fulfill()
        } catch {
            XCTFail("Wrong error \(error)")
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_format_noPluralsLocalizedValue() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(
            format: .android,
            localizationsDictionary: ["key": LocalizationItem.string(value: "localized_value")])

        let throwExpectaction = self.expectation(description: "Throw expectation")
        do {
            _ = try localizableFormatter.format(localization)
        } catch StringsDictFormatter.Error.noPlurals {
            throwExpectaction.fulfill()
        } catch {
            XCTFail("Wrong error \(error)")
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_stringsDict_onePluralLocalizedValue() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(format: .android, localizationsDictionary: [
            "key2": LocalizationItem.string(value: "localized_value2"),
            "key0": LocalizationItem.string(value: "localized_value0"),
            "pluralKey": LocalizationItem.plurals(values: [
                .zero: "zero_value",
                .other: "other_value"
                ]),
            "key1": LocalizationItem.string(value: "localized_value1")
            ])
        let expectedStringsDict = ["pluralKey":
            [
                "NSStringLocalizedFormatKey": "%#@elements@",
                "elements": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "zero": "zero_value",
                    "other": "other_value"
                ]
            ]
        ]

        do {
            let stringsDict = try localizableFormatter.stringsDict(from: localization)

            // THEN:
            XCTAssertEqual(expectedStringsDict as NSDictionary, stringsDict)
        } catch {
            XCTFail("No error should have been thrown \(error)")
        }
    }

    func test_stringsDict_multiplePluralLocalizedValue() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(format: .android, localizationsDictionary: [
            "key2": LocalizationItem.string(value: "localized_value2"),
            "pluralKey0": LocalizationItem.plurals(values: [
                .zero: "zero_value0",
                .other: "other_value0"
                ]),
            "key1": LocalizationItem.string(value: "localized_value1"),
            "pluralKey2": LocalizationItem.plurals(values: [
                .one: "one_value2",
                .other: "other_value2"
                ]),
            "pluralKey1": LocalizationItem.plurals(values: [
                .few: "few_value1",
                .other: "other_value1"
                ])
            ])
        let expectedStringsDict = [
            "pluralKey0": [
                "NSStringLocalizedFormatKey": "%#@elements@",
                "elements": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "zero": "zero_value0",
                    "other": "other_value0"
                ]
            ],
            "pluralKey1": [
                "NSStringLocalizedFormatKey": "%#@elements@",
                "elements": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "few": "few_value1",
                    "other": "other_value1"
                ]
            ],
            "pluralKey2": [
                "NSStringLocalizedFormatKey": "%#@elements@",
                "elements": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "one": "one_value2",
                    "other": "other_value2"
                ]
            ]
        ]

        do {
            let stringsDict = try localizableFormatter.stringsDict(from: localization)

            XCTAssertEqual(expectedStringsDict as NSDictionary, stringsDict)
        } catch {
            XCTFail("No error should have been thrown \(error)")
        }
    }

    func test_stringsDict_missingOtherValue() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(format: .android, localizationsDictionary: [
            "pluralKey": LocalizationItem.plurals(values: [.zero: "zero_value"])
            ])

        let throwExpectaction = self.expectation(description: "Throw expectation")
        do {
            _ = try localizableFormatter.format(localization)
        } catch StringsDictFormatter.Error.missingOtherKey {
            throwExpectaction.fulfill()
        } catch {
            XCTFail("Wrong error \(error)")
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_stringsDict_onePluralLocalizedValue_WithFormatParameter() {
        let localizableFormatter = StringsDictFormatter()
        let localization = LocalizationMap(format: .android, localizationsDictionary: [
            "pluralKey": LocalizationItem.plurals(values: [
                .zero: "zero_value",
                .other: "%1$s values"
                ])
            ])
        let expectedStringsDict = ["pluralKey":
            [
                "NSStringLocalizedFormatKey": "%#@elements@",
                "elements": [
                    "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
                    "NSStringFormatValueTypeKey": "d",
                    "zero": "zero_value",
                    "other": "%1$@ values"
                ]
            ]
        ]

        do {
            let stringsDict = try localizableFormatter.stringsDict(from: localization)

            XCTAssertEqual(expectedStringsDict as NSDictionary, stringsDict)
        } catch {
            XCTFail("No error should have been thrown \(error)")
        }
    }
}
