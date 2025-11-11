//
//  DevicesListTests.swift
//  nami companionUITests
//
//  Created by automation on splitting tests.
//

import XCTest

extension nami_companionUITests {

    func testDevicesListShowsAddMenuOptions() throws {
        let sessionCode = try requireSessionCode()
        let devicesListNavigationBar = navigateToDevicesList(sessionCode: sessionCode)

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
