//
//  CLIActionTests.swift
//
//  Created by Sébastien Duperron on 14/05/2016.
//  Copyright © 2016 Sébastien Duperron
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest

class CLIActionTests: XCTestCase {

    func test_unknownAction() {
        let expectThrownError = self.expectationWithDescription("Thrown error")

        do {
            _ = try CLIAction(actionName: "toto", anonymousArguments: [], namedArguments: [:])
        } catch CLIAction.Error.unknownAction(actionName: "toto") {
            expectThrownError.fulfill()
        } catch {
            XCTFail("Unexpected error")
        }

        self.waitForExpectationsWithTimeout(1, handler: nil)
    }

    func test_helpAction() {
        guard let action = try? CLIAction(actionName: "help", anonymousArguments: [], namedArguments: [:])
            else { XCTFail(); return }

        XCTAssertEqual(CLIAction.help, action)
    }

}
