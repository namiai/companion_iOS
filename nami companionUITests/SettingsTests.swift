//
//  SettingsTests.swift
//  nami companionUITests
//
//  Created by automation on splitting tests.
//

import CoreGraphics
import Foundation
import XCTest

extension nami_companionUITests {

    func testSettingsScreenShowsExpectedEntries() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        let listContainer = element(withIdentifier: "settings_list_container")
        XCTAssertTrue(listContainer.exists, "Settings list container not found.")

        let expectedIdentifiers = [
            "pins_list_item",
            "entry_exit_delay_list_item",
            "sensitivity_list_item",
        ]

        for identifier in expectedIdentifiers {
            let item = element(withIdentifier: identifier)
            XCTAssertTrue(item.exists, "Settings entry '\(identifier)' not found.")
        }
    }

    func testEntryExitDelaysWorkflow() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        let entryExitDelaysCell = element(withIdentifier: "entry_exit_delay_list_item")
        entryExitDelaysCell.tapOrCoordinate()

        let entryExitLayout = app.otherElements["entry_exit_delays_layout"]
        XCTAssertTrue(entryExitLayout.waitForExistence(timeout: 5), "Entry & exit delays layout not found.")

        let entryExitContainer = app.otherElements["entry_exit_delay_container"]
        XCTAssertTrue(entryExitContainer.waitForExistence(timeout: 5), "Entry & exit delays container not found.")

        let entryDelayCard = app.otherElements["entry_delay_card"]
        XCTAssertTrue(entryDelayCard.waitForExistence(timeout: 5), "Entry delay card not found.")

        let exitDelayCard = app.otherElements["exit_delay_card"]
        XCTAssertTrue(exitDelayCard.waitForExistence(timeout: 5), "Exit delay card not found.")

        let entryDelaySelector = app.otherElements["entry_delay_selector"]
        XCTAssertTrue(entryDelaySelector.waitForExistence(timeout: 5), "Entry delay selector not found.")

        let exitDelaySelector = app.otherElements["exit_delay_selector"]
        XCTAssertTrue(exitDelaySelector.waitForExistence(timeout: 5), "Exit delay selector not found.")

        let entryDelayHeader = app.staticTexts["Entry delay"]
        XCTAssertTrue(entryDelayHeader.waitForExistence(timeout: 5), "Entry & exit delays screen did not appear.")

        let saveButton = app.otherElements["save_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button not found on Entry & exit delays screen.")

        saveButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        XCTAssertTrue(entryDelayHeader.exists, "Entry & exit delays screen unexpectedly dismissed after tapping disabled save button.")

        let helpButton = Self.helpButton(in: app)
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5), "Help button not found on Entry & exit delays screen.")
        helpButton.tap()

        XCTAssertTrue(Self.dismissHelpIfPresented(app: app, timeout: 10), "Help screen did not appear or failed to dismiss.")
        XCTAssertTrue(entryDelayHeader.waitForExistence(timeout: 5), "Entry & exit delays screen did not reappear after closing help.")

        let entryDelayValueLabel = entryDelaySelector.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "seconds")).firstMatch
        XCTAssertTrue(entryDelayValueLabel.exists, "Entry delay value label not found.")
        let exitDelayValueLabel = exitDelaySelector.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "seconds")).firstMatch
        XCTAssertTrue(exitDelayValueLabel.exists, "Exit delay value label not found.")

        let entryDelayInitialValue = entryDelayValueLabel.label
        entryDelaySelector.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let entryDelayOptions = [
            "0 seconds",
            "30 seconds",
            "45 seconds",
            "60 seconds",
            "120 seconds",
        ]

        for option in entryDelayOptions {
            XCTAssertTrue(app.staticTexts[option].waitForExistence(timeout: 5), "Entry delay option '\(option)' not found.")
        }

        let entryDelayNewValue = entryDelayOptions.first { $0 != entryDelayInitialValue } ?? entryDelayOptions.last!
        selectDropdownOption(entryDelayNewValue, in: entryDelaySelector)
        XCTAssertTrue(entryDelayValueLabel.waitForLabel(entryDelayNewValue, timeout: 5), "Entry delay value did not update.")

        let exitDelayInitialValue = exitDelayValueLabel.label
        exitDelaySelector.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let exitDelayOptions = [
            "30 seconds",
            "45 seconds",
            "60 seconds",
            "120 seconds",
        ]

        for option in exitDelayOptions {
            XCTAssertTrue(app.staticTexts[option].waitForExistence(timeout: 5), "Exit delay option '\(option)' not found.")
        }

        let exitDelayNewValue = exitDelayOptions.first { $0 != exitDelayInitialValue } ?? exitDelayOptions.last!
        selectDropdownOption(exitDelayNewValue, in: exitDelaySelector)
        XCTAssertTrue(exitDelayValueLabel.waitForLabel(exitDelayNewValue, timeout: 5), "Exit delay value did not update.")

        saveButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        XCTAssertTrue(entryDelayHeader.waitToDisappear(timeout: 5), "Entry & exit delays screen did not dismiss after saving.")
        XCTAssertTrue(app.cells.staticTexts["Entry & exit delays"].waitForExistence(timeout: 5), "Settings list did not reappear after saving entry & exit delays.")
    }
}
