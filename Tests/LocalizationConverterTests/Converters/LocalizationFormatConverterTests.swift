//
//  LocalizationFormatConverterTests.swift
//
//  Created by Sébastien Duperron on 27/09/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class LocalizationFormatConverterTests: XCTestCase {

    func test_convertedLocalization_android_to_ios() {
        // GIVEN: some android formatted localization
        let androidLocalization = LocalizationMap(format: .android, localizationsDictionary: [
            "NoFormatValue": .string(value: "LocalizedValue"),
            "DecimalValue": .string(value: "A count: %d"),
            "StringValue": .string(value: "Hello %s!"),
            "PluralValue": .plurals(values: [.other: "%s said %d mississippis"])
        ])

        // WHEN: we convert its format to ios
        let iosLocalization = androidLocalization.convertedLocalization(to: .ios)

        // THEN: we have the expected localized values
        XCTAssertEqual("LocalizedValue", iosLocalization["NoFormatValue"]?.debugDescription)
        XCTAssertEqual("A count: %d", iosLocalization["DecimalValue"]?.debugDescription)
        XCTAssertEqual("Hello %@!", iosLocalization["StringValue"]?.debugDescription)
        XCTAssertEqual("other:%@ said %d mississippis", iosLocalization["PluralValue"]?.debugDescription)
    }

    func test_convertedLocalization_android_to_android() {
        let androidLocalization = LocalizationMap(format: .android, localizationsDictionary: [
            "NoFormatValue": .string(value: "LocalizedValue"),
            "DecimalValue": .string(value: "A count: %d"),
            "StringValue": .string(value: "Hello %s!"),
            "PluralValue": .plurals(values: [.other: "%s said %d mississippis"])
        ])
        XCTAssertEqual(androidLocalization, androidLocalization.convertedLocalization(to: .android))
    }

    func test_convertedLocalization_ios_to_ios() {
        let iosLocalization = LocalizationMap(format: .ios, localizationsDictionary: [
            "NoFormatValue": .string(value: "LocalizedValue"),
            "DecimalValue": .string(value: "A count: %d"),
            "StringValue": .string(value: "Hello %@!"),
            "PluralValue": .plurals(values: [.other: "%@ said %d mississippis"])
        ])
        XCTAssertEqual(iosLocalization, iosLocalization.convertedLocalization(to: .ios))
    }
}
