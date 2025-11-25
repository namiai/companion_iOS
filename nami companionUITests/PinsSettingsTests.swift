//
//  PinsSettingsTests.swift
//  nami companionUITests
//

import XCTest

extension nami_companionUITests {

    func testPinsScreenReflectsCurrentState() throws {
        let sessionCode = try requireSessionCode()
        let state = openPinsSettings(sessionCode: sessionCode)
        let activeLayout: XCUIElement

        switch state {
        case let .list(layout):
            activeLayout = layout
            let pinListContainer = element(withIdentifier: "pin_list_container", within: layout)
            let collectionView = pinListContainer.descendants(matching: .collectionView).firstMatch
            XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "PIN collection view not found.")
            let firstPinCell = collectionView.cells.firstMatch
            XCTAssertTrue(firstPinCell.waitForExistence(timeout: 5), "Expected at least one PIN item in list state.")
        case let .empty(layout):
            activeLayout = layout
            let noPinsLayout = element(withIdentifier: "no_pins_layout", within: layout)
            XCTAssertTrue(noPinsLayout.exists, "No PINs layout missing in empty state.")
            XCTAssertTrue(element(withIdentifier: "no_pins_hero_image", within: layout).exists, "Empty state hero image missing.")
            XCTAssertTrue(element(withIdentifier: "no_pins_title", within: layout).exists, "Empty state title missing.")
            XCTAssertTrue(element(withIdentifier: "no_pins_subtitle", within: layout).exists, "Empty state subtitle missing.")
        }

        let createPinButton = element(withIdentifier: "create_pin_button", within: activeLayout)
        XCTAssertTrue(createPinButton.exists, "Create PIN button not found on active PINs layout.")

        let limitMessage = activeLayout.otherElements["pin_limit_message"]
        let limitVisible = limitMessage.exists && limitMessage.isHittable
        if limitVisible {
            XCTAssertFalse(createPinButton.isEnabled, "Create PIN button should be disabled when limit message is visible.")
        } else {
            XCTAssertTrue(createPinButton.isEnabled, "Create PIN button should be enabled when limit has not been reached.")
        }
    }

    func testCreatePinButtonOpensNamePinScreen() throws {
        let sessionCode = try requireSessionCode()
        let state = openPinsSettings(sessionCode: sessionCode)
        let activeLayout: XCUIElement
        switch state {
        case let .list(layout):
            activeLayout = layout
        case let .empty(layout):
            activeLayout = layout
        }

        let createPinButton = element(withIdentifier: "create_pin_button", within: activeLayout)
        let limitMessage = activeLayout.otherElements["pin_limit_message"]
        let limitVisible = limitMessage.exists && limitMessage.isHittable

        if !createPinButton.isEnabled {
            XCTAssertTrue(limitVisible, "Limit message not shown when Create PIN is disabled.")
            throw XCTSkip("Create PIN button disabled because maximum PINs reached.")
        }

        XCTAssertFalse(limitVisible, "Limit message should be hidden when new PINs can be created.")

        createPinButton.tapOrCoordinate()

        let namePinLayout = app.otherElements["name_pin_layout"]
        XCTAssertTrue(namePinLayout.waitForExistence(timeout: 5), "Name PIN screen did not appear after tapping Create PIN.")
    }
}
