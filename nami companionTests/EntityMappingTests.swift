// Copyright (c) nami.ai

@testable import nami_companion
import XCTest

/// Covers the `external-device-ids` request, its response decoding, and when the device list
/// state offers an entity picker tree.
final class EntityMappingTests: XCTestCase {
    /// The request targets the place's mapping for the given partner and carries the session token.
    func testExternalDeviceIdsRequestTargetsPlaceAndPartner() throws {
        let request = PlaceDevicesListViewModel.externalDeviceIdsRequest(
            baseUrl: URL(string: "https://api.example.com")!,
            placeId: 42,
            partnerId: "alarm_dot_com",
            accessToken: "token"
        )

        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(components.host, "api.example.com")
        XCTAssertEqual(components.path, "/places/42/external-device-ids")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "external_client_id", value: "alarm_dot_com")])
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    /// The partner id is sent as a query value, so reserved characters are escaped, not spliced in.
    func testExternalDeviceIdsRequestEscapesPartnerId() throws {
        let request = PlaceDevicesListViewModel.externalDeviceIdsRequest(
            baseUrl: URL(string: "https://api.example.com")!,
            placeId: 42,
            partnerId: "a&b=c",
            accessToken: "token"
        )

        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "external_client_id", value: "a&b=c")])
    }

    /// The backend wraps the mapping in `external_device_ids`.
    func testDecodesExternalDeviceIdsResponse() throws {
        let json = Data(#"{"external_device_ids":{"0A1B2C":"urn:device:100","alarm_dot_com:mz:z":"urn:zone:1"}}"#.utf8)

        let response = try JSONDecoder().decode(ExternalDeviceIdsResponse.self, from: json)

        XCTAssertEqual(response.externalDeviceIds, ["0A1B2C": "urn:device:100", "alarm_dot_com:mz:z": "urn:zone:1"])
    }

    /// A body without the wrapper key is a decoding error, not an empty mapping.
    func testRejectsResponseWithoutMappingKey() {
        let json = Data(#"{"0A1B2C":"urn:device:100"}"#.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(ExternalDeviceIdsResponse.self, from: json))
    }

    /// The tree is built once both the place and the mapping have loaded.
    func testEntityPickerTreeAppearsWhenPlaceAndMappingLoaded() {
        var state = PlaceDevicesListViewModel.State(partnerId: "alarm_dot_com")
        state.place = Self.place
        state.externalDeviceIds = ["zone-ext": "urn:zone:1"]

        XCTAssertEqual(state.entityPickerTree?.zones.first?.externalIds.map(\.externalId), ["zone-ext"])
    }

    /// Without the mapping, or without the place, there is no tree to show yet.
    func testEntityPickerTreeIsNilUntilBothLoad() {
        var placeOnly = PlaceDevicesListViewModel.State(partnerId: "alarm_dot_com")
        placeOnly.place = Self.place
        var mappingOnly = PlaceDevicesListViewModel.State(partnerId: "alarm_dot_com")
        mappingOnly.externalDeviceIds = ["zone-ext": "urn:zone:1"]

        XCTAssertNil(placeOnly.entityPickerTree)
        XCTAssertNil(mappingOnly.entityPickerTree)
    }

    private static let place = Place(
        id: 7,
        urn: "urn:place:7",
        name: "Home",
        zones: [Zone(id: 1, urn: "urn:zone:1", name: "Zone", rooms: [])]
    )
}
