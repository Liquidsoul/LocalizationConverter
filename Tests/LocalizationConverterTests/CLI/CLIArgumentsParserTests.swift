//
//  CLIArgumentsParserTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

@testable import LocalizationConverter

class CLIArgumentsParserTests: XCTestCase {

    func test_parseAction_noArguments() throws {
        // GIVEN: a parser
        let parser = CLIArgumentsParser()
        // GIVEN: an expected error
        let expectThrownError = self.expectation(description: "Thrown error")

        // WHEN: we try to parse an empty array of arguments
        do {
            _ = try parser.parseAction(from: [])
        } catch CLIArgumentsParser.Error.noAction {
            expectThrownError.fulfill()
        }

        // THEN: we got the expected error
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func test_parseAction_help() {
        // GIVEN: a parser
        let parser = CLIArgumentsParser()

        // WHEN: we pass help as the action
        let action = try? parser.parseAction(from: ["help"])

        // THEN: we got the expected help action
        XCTAssertEqual(CLIAction.help, action)
    }

}
