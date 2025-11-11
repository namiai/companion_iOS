//
//  SessionCodeScreenTests.swift
//  nami companionUITests
//
//  Created by automation on splitting tests.
//

import XCTest

extension nami_companionUITests {

    func testSessionCodeScreenElements() throws {
        XCTAssert(app.staticTexts["Please enter the session code acquired from the partner's application"].exists)
        XCTAssert(app.textFields["Session Code"].exists)
        XCTAssert(app.textFields["Client ID"].exists)
        XCTAssert(app.textFields["Base URL"].exists)
        XCTAssert(app.textFields["Country code"].exists)
        XCTAssert(app.textFields["Language"].exists)
        XCTAssert(app.buttons["Appearance, Light"].exists)
        XCTAssert(app.buttons["Measurement system, Metric"].exists)
        XCTAssert(app.buttons["Confirm"].exists)
    }

    func testSessionCodeScreenShowsDefaultValues() throws {
        let sessionCodeField = app.textFields["Session Code"]
        XCTAssert(sessionCodeField.exists)
        let sessionCodeValue = sessionCodeField.stringValue
        XCTAssertTrue(sessionCodeValue.isEmpty || sessionCodeValue == sessionCodeField.placeholderValue)

        XCTAssertEqual(app.textFields["Client ID"].stringValue, "nami_dev")
        let expectedBaseURL = templatesBaseURLOverride ?? "https://mobile-screens.nami.surf/divkit/v0.5.0/precompiled_layouts"
        XCTAssertEqual(app.textFields["Base URL"].stringValue, expectedBaseURL)
        XCTAssertEqual(app.textFields["Country code"].stringValue.lowercased(), "us")
        XCTAssertEqual(app.textFields["Language"].stringValue, "en-US")
        XCTAssertFalse(app.buttons["Confirm"].isEnabled)
    }

    func testConfirmButtonEnablesAfterEnteringSessionCode() throws {
        let sessionCodeField = app.textFields["Session Code"]
        XCTAssert(sessionCodeField.exists)
        XCTAssert(!app.buttons["Confirm"].isEnabled)
        sessionCodeField.tap()
        sessionCodeField.typeText(sessionCode ?? "ABC123")

        XCTAssertTrue(app.buttons["Confirm"].isEnabled)
    }
}
