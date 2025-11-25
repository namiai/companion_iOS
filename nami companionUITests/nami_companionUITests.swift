//
//  nami_companionUITests.swift
//  nami companionUITests
//
//  Created by Gleb Vodovozov on 16/10/25.
//

import CoreGraphics
import Foundation
import XCTest

final class nami_companionUITests: XCTestCase {

    private(set) var app: XCUIApplication!
    private(set) var sessionCode: String?
    private(set) var templatesBaseURLOverride: String?

    override func setUpWithError() throws {
        continueAfterFailure = false

        sessionCode = try Self.resolveSessionCode()
        if let override = ProcessInfo.processInfo.environment["NAMI_TEMPLATES_BASE_URL"]?.trimmingCharacters(in: .whitespacesAndNewlines), !override.isEmpty {
            templatesBaseURLOverride = override
        } else {
            templatesBaseURLOverride = nil
        }
        app = XCUIApplication()
        if let templatesBaseURLOverride {
            app.launchEnvironment["NAMI_TEMPLATES_BASE_URL"] = templatesBaseURLOverride
        }
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

}

extension XCUIElement {
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

    @discardableResult
    func waitForLabel(_ label: String, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "label == %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    @discardableResult
    func waitToDisappear(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    func primaryLabel(excluding excludedLabels: Set<String> = []) -> String {
        let labels = staticTexts.allElementsBoundByIndex
            .map(\.label)
            .filter { !$0.isEmpty && !excludedLabels.contains($0) }

        if let shortest = labels.min(by: { $0.count < $1.count }) {
            return shortest
        }

        let fallback = label
        if !fallback.isEmpty && !excludedLabels.contains(fallback) {
            return fallback
        }

        return labels.first ?? ""
    }

    func tapOrCoordinate() {
        if isHittable {
            tap()
        } else {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }
}

extension nami_companionUITests {
    func selectDropdownOption(_ label: String, in selector: XCUIElement, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "label == %@", label)
        let optionsQuery = selector.staticTexts.matching(predicate)
        let firstMatch = optionsQuery.firstMatch
        XCTAssertTrue(firstMatch.waitForExistence(timeout: timeout), "Dropdown option '\(label)' not found.")

        let candidates = optionsQuery.allElementsBoundByIndex
        guard let target = candidates.first(where: { $0.isHittable }) ?? candidates.last else {
            XCTFail("No tappable element found for dropdown option '\(label)'.")
            return
        }
        target.tap()
    }

    func requireSessionCode(file: StaticString = #filePath, line: UInt = #line) throws -> String {
        guard let sessionCode, !sessionCode.isEmpty else {
            throw XCTSkip("Failed to resolve session code; ensure NAMI_ACCESS_TOKEN is set.")
        }
        return sessionCode
    }

    @discardableResult
    func navigateToDevicesList(sessionCode: String) -> XCUIElement {
        let sessionCodeField = app.textFields["Session Code"]
        XCTAssertTrue(sessionCodeField.waitForExistence(timeout: 5))
        sessionCodeField.tap()
        sessionCodeField.clearAndEnterText(sessionCode)

        // Base URL is pre-populated by the app when NAMI_TEMPLATES_BASE_URL is provided.
        if let templatesBaseURLOverride {
            let baseURLField = app.textFields["Base URL"]
            XCTAssertTrue(baseURLField.waitForExistence(timeout: 2), "Base URL text field not found.")
            XCTAssertEqual(baseURLField.stringValue, templatesBaseURLOverride, "Base URL field does not reflect NAMI_TEMPLATES_BASE_URL override.")
        }

        let confirmButton = app.buttons["Confirm"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()

        let devicesListNavigationBar = app.navigationBars["Place devices list"]
        XCTAssertTrue(devicesListNavigationBar.waitForExistence(timeout: 10))
        return devicesListNavigationBar
    }

    func navigateToSettingsList(sessionCode: String) {
        let devicesListNavigationBar = navigateToDevicesList(sessionCode: sessionCode)
        let addButton = devicesListNavigationBar.buttons.firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add (+) button not found on devices list screen.")
        addButton.tap()

        let showSettingsButton = app.buttons["Show settings"]
        XCTAssertTrue(showSettingsButton.waitForExistence(timeout: 5), "Show settings menu item not found.")
        showSettingsButton.tap()

        _ = element(withIdentifier: "settings_layout")
    }

    enum PinsScreenState {
        case list(layout: XCUIElement)
        case empty(layout: XCUIElement)
    }

    @discardableResult
    func openPinsSettings(sessionCode: String) -> PinsScreenState {
        navigateToSettingsList(sessionCode: sessionCode)

        let pinsCell = element(withIdentifier: "pins_list_item")
        pinsCell.tapOrCoordinate()

        _ = element(withIdentifier: "settings_pins_layout")

        let listLayout = app.otherElements["settings_pins_list_layout"]
        XCTAssertTrue(listLayout.waitForExistence(timeout: 5), "Settings PINs list layout not found.")

        let emptyLayout = app.otherElements["settings_pins_empty_layout"]
        XCTAssertTrue(emptyLayout.waitForExistence(timeout: 5), "Settings PINs empty layout not found.")

        let emptyHero = app.images["no_pins_hero_image"]
        if (emptyHero.waitForExistence(timeout: 1) && emptyHero.isHittable) || emptyLayout.isHittable {
            return .empty(layout: emptyLayout)
        }

        let pinListContainer = app.otherElements["pin_list_container"]
        XCTAssertTrue(pinListContainer.waitForExistence(timeout: 5), "PIN list container not found.")
        return .list(layout: listLayout)
    }

    func sensitivitySettingsCell(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        element(withIdentifier: "sensitivity_list_item", timeout: timeout, file: file, line: line)
    }

    func sensitivitySummaryLabel(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement? {
        let cell = sensitivitySettingsCell(timeout: timeout, file: file, line: line)
        let summaryCandidates = cell.staticTexts.allElementsBoundByIndex.filter {
            $0.label.caseInsensitiveCompare("Sensitivity") != .orderedSame
        }
        return summaryCandidates.first
    }

    func sensitivitySummaryValue(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> String {
        guard let label = sensitivitySummaryLabel(timeout: timeout, file: file, line: line) else {
            return ""
        }
        return label.label
    }

    func openSensitivitySettings(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sensitivitySettingsCell(timeout: timeout, file: file, line: line)
        cell.tapOrCoordinate()
    }

    func element(withIdentifier identifier: String, within container: XCUIElement? = nil, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let root = container ?? app
        let candidates: [XCUIElement] = [
            root.otherElements[identifier],
            root.buttons[identifier],
            root.cells[identifier],
            root.collectionViews.cells[identifier],
            root.scrollViews.otherElements[identifier],
            root.collectionViews.otherElements[identifier],
            root.staticTexts[identifier],
            root.descendants(matching: .any)[identifier]
        ]

        for element in candidates {
            if element.waitForExistence(timeout: timeout) {
                return element
            }
        }

        XCTFail("Element with identifier '\(identifier)' not found.", file: file, line: line)
        return candidates.last ?? app.otherElements.firstMatch
    }

    @discardableResult
    func waitForSensitivitySummary(_ expected: String, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let label = sensitivitySummaryLabel(timeout: 1, file: file, line: line),
               label.label == expected {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return false
    }

    struct SensitivityCard {
        let identifier: String
        let title: String
        let element: XCUIElement
    }

    func loadSensitivityCards(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> [SensitivityCard] {
        let identifiers = ["sensitivity_level_card_low", "sensitivity_level_card_default", "sensitivity_level_card_high"]
        var cards: [SensitivityCard] = []

        for identifier in identifiers {
            let element = element(withIdentifier: identifier, timeout: timeout, file: file, line: line)
            let title = element.primaryLabel()
            cards.append(SensitivityCard(identifier: identifier, title: title, element: element))
        }

        return cards
    }

    func learnMoreElement(in infoCard: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let direct = infoCard.staticTexts["Learn more"]
        if direct.exists && direct.isHittable {
            return direct
        }

        if direct.waitForExistence(timeout: timeout) {
            return direct
        }

        let predicate = NSPredicate(format: "label CONTAINS[c] %@", "learn more")
        let fallback = infoCard.staticTexts.matching(predicate).firstMatch
        XCTAssertTrue(fallback.waitForExistence(timeout: timeout), "'Learn more' text not found inside info card.", file: file, line: line)
        return fallback
    }

    static func resolveSessionCode() throws -> String {
        return try fetchSessionCodeUsingAccessToken()
    }

    static func fetchSessionCodeUsingAccessToken(timeout: TimeInterval = 15) throws -> String {
        guard let accessToken = ProcessInfo.processInfo.environment["NAMI_ACCESS_TOKEN"], !accessToken.isEmpty else {
            throw XCTSkip("NAMI_ACCESS_TOKEN environment variable not provided; skipping UI tests that require session code creation.")
        }

        var request = URLRequest(url: URL(string: "https://mangahume.nami.surf/commissioningv1/session-codes")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(SessionCodePayload())

        let (data, response) = try performSynchronousRequest(request: request, timeout: timeout)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SessionCodeError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SessionCodeError.requestFailed(statusCode: httpResponse.statusCode, body: data)
        }

        let sessionCode = try JSONDecoder().decode(SessionCodeResponse.self, from: data).code
        guard !sessionCode.isEmpty else {
            throw SessionCodeError.emptyCode
        }
        return sessionCode
    }

    static func performSynchronousRequest(request: URLRequest, timeout: TimeInterval) throws -> (Data, URLResponse) {
        let semaphore = DispatchSemaphore(value: 0)
        var capturedData: Data?
        var capturedResponse: URLResponse?
        var capturedError: Error?

        let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, response, error in
            capturedData = data
            capturedResponse = response
            capturedError = error
            semaphore.signal()
        }
        task.resume()

        if semaphore.wait(timeout: .now() + timeout) == .timedOut {
            task.cancel()
            throw SessionCodeError.timedOut
        }

        if let error = capturedError {
            throw error
        }

        guard let data = capturedData, let response = capturedResponse else {
            throw SessionCodeError.missingData
        }

        return (data, response)
    }

    struct SessionCodePayload: Encodable {
        let profileID: String = "installer"
        let redirectURI: String = "https://app.nami.test/commissioning-redirect"

        enum CodingKeys: String, CodingKey {
            case profileID = "profile_id"
            case redirectURI = "redirect_uri"
        }
    }

    struct SessionCodeResponse: Decodable {
        let code: String
    }

    enum SessionCodeError: Error, LocalizedError {
        case timedOut
        case missingData
        case invalidResponse
        case requestFailed(statusCode: Int, body: Data)
        case emptyCode

        var errorDescription: String? {
            switch self {
            case .timedOut:
                return "Timed out while waiting for session code response."
            case .missingData:
                return "Session code response missing data."
            case .invalidResponse:
                return "Session code response was not HTTP."
            case let .requestFailed(statusCode, body):
                let bodyString = String(data: body, encoding: .utf8) ?? "<unreadable>"
                return "Session code request failed with status \(statusCode): \(bodyString)"
            case .emptyCode:
                return "Session code response did not contain a code."
            }
        }
    }
}

extension nami_companionUITests {
    static func helpButton(in app: XCUIApplication) -> XCUIElement {
        let questionImage = app.images.matching(identifier: "Question").firstMatch
        if questionImage.exists {
            return questionImage
        }

        let candidateButtons = ["Help", "?", "Info", "Information", "Learn more"]
        for label in candidateButtons {
            let button = app.buttons[label]
            if button.exists { return button }
        }

        if app.buttons.count > 0 {
            return app.buttons.element(boundBy: app.buttons.count - 1)
        }

        return questionImage
    }

    static func dismissHelpIfPresented(app: XCUIApplication, timeout: TimeInterval) -> Bool {
        let webView = app.webViews.firstMatch
        let halfTimeout = timeout / 2
        let webViewAppeared = webView.waitForExistence(timeout: halfTimeout)

        let closeButtonLabels = ["Done", "Close", "Cancel", "Dismiss"]
        var closeButton: XCUIElement?
        for label in closeButtonLabels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: halfTimeout / Double(closeButtonLabels.count)) {
                closeButton = button
                break
            }
        }

        if closeButton == nil {
            let safariDoneButton = app.buttons["SafariViewControllerDoneButton"]
            if safariDoneButton.waitForExistence(timeout: halfTimeout) {
                closeButton = safariDoneButton
            }
        }

        guard webViewAppeared || closeButton != nil else {
            return false
        }

        guard let button = closeButton else {
            return false
        }

        button.tap()
        return true
    }
}
