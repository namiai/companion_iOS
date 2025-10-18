//
//  nami_companionUITests.swift
//  nami companionUITests
//
//  Created by Gleb Vodovozov on 16/10/25.
//

import Foundation
import XCTest

final class nami_companionUITests: XCTestCase {

    private var app: XCUIApplication!
    private var sessionCode: String?

    override func setUpWithError() throws {
        continueAfterFailure = false

        sessionCode = try Self.resolveSessionCode()
        app = XCUIApplication()
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

    func testSessionCodeSubmissionNavigatesToDevicesListAndSettings() throws {
        guard let sessionCode, !sessionCode.isEmpty else {
            throw XCTSkip("Failed to resolve session code; ensure NAMI_ACCESS_TOKEN is set.")
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
        XCTAssertTrue(devicesListNavigationBar.waitForExistence(timeout: 10))

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

        let showSettingsButton = app.buttons["Show settings"]
        XCTAssertTrue(showSettingsButton.waitForExistence(timeout: 5))
        showSettingsButton.tap()

        let expectedSettingsEntries = [
            "PINs",
            "Entry & exit delays",
            "Sensitivity",
        ]

        for entry in expectedSettingsEntries {
            XCTAssertTrue(app.staticTexts[entry].waitForExistence(timeout: 10), "Expected settings entry '\(entry)' not found.")
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

private extension nami_companionUITests {
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
