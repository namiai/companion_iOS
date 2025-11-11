//
//  SensitivityTests.swift
//  nami companionUITests
//
//  Created by automation on splitting tests.
//

import Foundation
import XCTest

extension nami_companionUITests {

    func testSensitivityScreenRendersExpectedContent() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        openSensitivitySettings()

        let sensitivityLayout = element(withIdentifier: "sensitivity_layout")

        let contentContainer = element(withIdentifier: "sensitivity_content_container")

        let gallery = element(withIdentifier: "sensitivity_level_gallery")

        let cards = loadSensitivityCards()
        XCTAssertEqual(cards.count, 3, "Expected to find exactly three sensitivity level cards.")
        for card in cards {
            XCTAssertFalse(card.title.isEmpty, "Sensitivity card '\(card.identifier)' did not expose a title.")
        }

        let infoCard = element(withIdentifier: "info_card")
    }

    func testSensitivityLearnMoreOpensInAppBrowser() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        openSensitivitySettings()

        let sensitivityLayout = element(withIdentifier: "sensitivity_layout")

        let infoCard = element(withIdentifier: "info_card")

        let learnMoreElement = learnMoreElement(in: infoCard)
        learnMoreElement.tap()

        XCTAssertTrue(Self.dismissHelpIfPresented(app: app, timeout: 10), "In-app browser did not appear after tapping Learn more.")
    }

    func testChangingSensitivityUpdatesSettingsSummary() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        let initialSummary = sensitivitySummaryValue()

        openSensitivitySettings()

        let sensitivityLayout = element(withIdentifier: "sensitivity_layout")

        let cards = loadSensitivityCards()
        let targetCard = cards.first {
            !$0.title.isEmpty && $0.title.caseInsensitiveCompare(initialSummary) != .orderedSame
        } ?? cards.last
        XCTAssertNotNil(targetCard, "Failed to find an alternative sensitivity card to select.")

        guard let nextCard = targetCard else { return }

        let expectedSummary = nextCard.title
        nextCard.element.tap()

        XCTAssertTrue(sensitivityLayout.waitToDisappear(timeout: 5), "Sensitivity screen did not dismiss after selecting a level.")
        XCTAssertTrue(app.staticTexts["Sensitivity"].waitForExistence(timeout: 5), "Settings list did not reappear after selecting a sensitivity level.")
        XCTAssertTrue(waitForSensitivitySummary(expectedSummary, timeout: 5), "Sensitivity summary did not update to '\(expectedSummary)'.")
    }
}
