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

    private var app: XCUIApplication!
    private var sessionCode: String?
    private var templatesBaseURLOverride: String?

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

    func testSettingsScreenShowsExpectedEntries() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        let expectedSettingsEntries = [
            "PINs",
            "Entry & exit delays",
            "Sensitivity",
        ]

        for entry in expectedSettingsEntries {
            XCTAssertTrue(app.staticTexts[entry].waitForExistence(timeout: 5), "Expected settings entry '\(entry)' not found.")
        }
    }

    func testEntryExitDelaysWorkflow() throws {
        let sessionCode = try requireSessionCode()
        navigateToSettingsList(sessionCode: sessionCode)

        let entryExitDelaysCell = app.staticTexts["Entry & exit delays"]
        XCTAssertTrue(entryExitDelaysCell.waitForExistence(timeout: 5))
        entryExitDelaysCell.tap()

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

}

private extension nami_companionUITests {
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

        XCTAssertTrue(app.staticTexts["PINs"].waitForExistence(timeout: 5), "Settings list did not appear.")
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

private extension nami_companionUITests {
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
