// Copyright (c) nami.ai

@testable import nami_companion
import XCTest

/// Covers decoding of the session activation's `session_parameters`, which carries the partner id
/// the companion passes to entity-scoped settings.
final class SessionParametersTests: XCTestCase {
    /// `partner_id` decodes into `partnerId`.
    func testDecodesPartnerId() throws {
        let parameters = try JSONDecoder().decode(SessionParameters.self, from: Self.json(partnerId: #""alarm_dot_com""#))

        XCTAssertEqual(parameters.partnerId, "alarm_dot_com")
    }

    /// A place without a managing client has no `partner_id`; the session still decodes.
    func testDecodesWithoutPartnerId() throws {
        let parameters = try JSONDecoder().decode(SessionParameters.self, from: Self.json(partnerId: nil))

        XCTAssertNil(parameters.partnerId)
        XCTAssertEqual(parameters.partnerName, "Partner")
    }

    /// An explicit `null` reads as no partner id.
    func testDecodesNullPartnerId() throws {
        let parameters = try JSONDecoder().decode(SessionParameters.self, from: Self.json(partnerId: "null"))

        XCTAssertNil(parameters.partnerId)
    }

    /// Builds a `session_parameters` body.
    ///
    /// - Parameter partnerId: The raw JSON value for `partner_id`, or `nil` to omit the key.
    /// - Returns: The encoded body.
    private static func json(partnerId: String?) -> Data {
        let partnerField = partnerId.map { #""partner_id":\#($0),"# } ?? ""
        return Data("""
        {
            "permissions": ["devices.read"],
            "mode": "companion",
            "flat_mode": {},
            "partner_name": "Partner",
            \(partnerField)
            "redirect_uri": "https://example.com/return"
        }
        """.utf8)
    }
}
