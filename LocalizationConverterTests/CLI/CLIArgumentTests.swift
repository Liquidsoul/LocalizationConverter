//
//  CLIArgumentTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

class CLIArgumentTests: XCTestCase {

    func test_unparseableArgument() throws {
        let expectation = self.expectationWithDescription("Thrown error")
        do {
            _ = try CLIArgument(argument: "")
        } catch CLIArgument.Error.unparseableArgument(argument: let arg) {
            XCTAssertEqual("", arg)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(1, handler: nil)
    }

    func test_namedValue() {
        guard let namedArgument = try? CLIArgument(argument: "--name=value") else { XCTFail(); return }

        XCTAssertEqual(CLIArgument.namedValue(name: "name", value: "value"), namedArgument)
    }

    func test_anonymousValue() {
        guard let anonymousArgument = try? CLIArgument(argument: "file.name") else { XCTFail(); return }

        XCTAssertEqual(CLIArgument.anonymousValue(value: "file.name"), anonymousArgument)
    }
}

extension CLIArgumentTests {
    func test_decompose() {
        let arguments: [CLIArgument] = [
            .anonymousValue(value: "anonymousValue"),
            .namedValue(name: "name", value: "value")
        ]

        let (anonymousValues, namedValues) = CLIArgument.decompose(arguments: arguments)

        XCTAssertEqual((["anonymousValue"]), anonymousValues)
        XCTAssertEqual(["name":"value"], namedValues)
    }
}
