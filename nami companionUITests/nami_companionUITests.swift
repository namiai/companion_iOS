//
//  nami_companionUITests.swift
//  nami companionUITests
//
//  Created by Gleb Vodovozov on 16/10/25.
//

import XCTest

final class nami_companionUITests: XCTestCase {

    private var app: XCUIApplication!
    private var sessionCode: String?

    override func setUpWithError() throws {
        continueAfterFailure = false
        sessionCode = ProcessInfo.processInfo.environment["NAMI_SESSION_CODE"]
        app = XCUIApplication()
        if let sessionCode, !sessionCode.isEmpty {
            app.launchEnvironment["NAMI_SESSION_CODE"] = sessionCode
        }
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSessionCodeScreenElements() throws {
        XCTAssert(app.staticTexts["Please enter the session code acquired from the partner's application"].exists)
        XCTAssert(app.textFields["Session Code"].exists)
        XCTAssert(app.textFields["Client ID"].exists)
        XCTAssert(app.textFields["Base URL"].exists)
        XCTAssert(app.textFields["Country code"].exists)
        XCTAssert(app.textFields["Language"].exists)
        XCTAssert(app.buttons["Appearance, System"].exists)
        XCTAssert(app.buttons["Measurement system, Metric"].exists)
        XCTAssert(app.buttons["Confirm"].exists)
    }

    func testSessionCodeScreenShowsDefaultValues() throws {
        let sessionCodeField = app.textFields["Session Code"]
        XCTAssert(sessionCodeField.exists)
        let sessionCodeValue = sessionCodeField.stringValue
        XCTAssertTrue(sessionCodeValue.isEmpty || sessionCodeValue == sessionCodeField.placeholderValue)

        XCTAssertEqual(app.textFields["Client ID"].stringValue, "nami_dev")
        XCTAssertEqual(app.textFields["Base URL"].stringValue, "https://mobile-screens.nami.surf/divkit/v0.5.0/precompiled_layouts")
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

    func testSessionCodeSubmissionNavigatesToDevicesList() throws {
        guard let sessionCode, !sessionCode.isEmpty else {
            throw XCTSkip("NAMI_SESSION_CODE environment variable not provided; skipping submission flow test.")
        }

        let sessionCodeField = app.textFields["Session Code"]
        XCTAssertTrue(sessionCodeField.waitForExistence(timeout: 5))
        sessionCodeField.tap()
        sessionCodeField.clearAndEnterText(sessionCode)

        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        let devicesListNavigationBar = app.navigationBars["Place devices list"]
        XCTAssertTrue(devicesListNavigationBar.waitForExistence(timeout: 30))

        let addButton = devicesListNavigationBar.buttons.firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add (+) button not found on devices list screen.")
        addButton.tap()

        let expectedMenuItems = [
            "Add Single Device",
            "Start Setup Guide",
            "Show settings",
        ]

        for item in expectedMenuItems {
            XCTAssertTrue(app.buttons[item].waitForExistence(timeout: 2), "Menu item '\(item)' not found.")
        }
    }
}

private extension XCUIElement {
    var stringValue: String {
        (value as? String) ?? ""
    }

    func clearAndEnterText(_ text: String) {
        guard let existingValue = value as? String, !existingValue.isEmpty else {
            typeText(text)
            return
        }

        tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingValue.count)
        typeText(deleteString)
        typeText(text)
    }
}
