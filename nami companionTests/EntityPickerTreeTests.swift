// Copyright (c) nami.ai

import NamiPairingFramework
@testable import nami_companion
import XCTest

/// Covers how the entity picker attaches `external-device-ids` mapping keys to the place's
/// zones, rooms and devices.
final class EntityPickerTreeTests: XCTestCase {
    /// Keys attach to the zone, room and device whose URN equals the mapped URN, in topology order.
    func testAttachesKeysToEntitiesByUrn() {
        let tree = EntityPickerTree(
            zones: [Self.zone],
            devices: [Self.device],
            mapping: [
                "alarm_dot_com:mz:zone-a": "urn:zone:1",
                "alarm_dot_com:ss:zone-a": "urn:zone:1",
                "room-ext": "urn:room:10",
                "0A1B2C": "urn:device:100",
            ]
        )

        XCTAssertEqual(tree.zones.map(\.urn), ["urn:zone:1"])
        XCTAssertEqual(tree.zones[0].externalIds.map(\.externalId), ["alarm_dot_com:mz:zone-a", "alarm_dot_com:ss:zone-a"])
        XCTAssertEqual(tree.zones[0].rooms.map(\.urn), ["urn:room:10"])
        XCTAssertEqual(tree.zones[0].rooms[0].externalIds.map(\.externalId), ["room-ext"])
        XCTAssertEqual(tree.zones[0].rooms[0].devices.map(\.urn), ["urn:device:100"])
        XCTAssertEqual(tree.zones[0].rooms[0].devices[0].externalIds, [
            EntityPickerTree.ExternalID(externalId: "0A1B2C", urn: "urn:device:100"),
        ])
        XCTAssertEqual(tree.unmatched, [])
    }

    /// Keys mapped to URNs outside the loaded place stay pickable in `unmatched`, sorted by key.
    func testKeepsKeysForUnknownUrnsInUnmatched() {
        let tree = EntityPickerTree(
            zones: [Self.zone],
            devices: [Self.device],
            mapping: [
                "zz-stale": "urn:device:999",
                "aa-other-place": "urn:zone:2",
                "0A1B2C": "urn:device:100",
            ]
        )

        XCTAssertEqual(tree.unmatched.map(\.externalId), ["aa-other-place", "zz-stale"])
        XCTAssertEqual(tree.zones[0].rooms[0].devices[0].externalIds.map(\.externalId), ["0A1B2C"])
    }

    /// URNs match only exactly: a case or prefix variant attaches nowhere and lands in `unmatched`.
    func testDoesNotMatchUrnsLoosely() {
        let tree = EntityPickerTree(
            zones: [Self.zone],
            devices: [Self.device],
            mapping: [
                "upper": "URN:ZONE:1",
                "prefix": "urn:room:1",
            ]
        )

        XCTAssertEqual(tree.zones[0].externalIds, [])
        XCTAssertEqual(tree.zones[0].rooms[0].externalIds, [])
        XCTAssertEqual(tree.unmatched.map(\.externalId), ["prefix", "upper"])
    }

    /// Devices sit under the room with their `roomId`; a device in no listed room is not shown,
    /// so its key goes to `unmatched`.
    func testListsDevicesUnderTheirRoomOnly() {
        let roomless = Device(id: NamiDeviceID(200), urn: "urn:device:200", name: "Hallway", type: nil, roomId: nil)
        let tree = EntityPickerTree(
            zones: [Self.zone],
            devices: [Self.device, roomless],
            mapping: ["roomless-ext": "urn:device:200"]
        )

        XCTAssertEqual(tree.zones[0].rooms[0].devices.map(\.urn), ["urn:device:100"])
        XCTAssertEqual(tree.unmatched.map(\.externalId), ["roomless-ext"])
    }

    /// Empty names fall back to the entity kind, and to the device type for unnamed devices.
    func testFallsBackToKindTitlesForEmptyNames() {
        let zone = Zone(id: 1, urn: "urn:zone:1", name: "", rooms: [Room(id: 10, urn: "urn:room:10", name: "")])
        let typed = Device(id: NamiDeviceID(100), urn: "urn:device:100", name: "", type: "contact_sensor", roomId: 10)
        let untyped = Device(id: NamiDeviceID(101), urn: "urn:device:101", name: "", type: nil, roomId: 10)

        let tree = EntityPickerTree(zones: [zone], devices: [typed, untyped], mapping: [:])

        XCTAssertEqual(tree.zones[0].title, "Zone")
        XCTAssertEqual(tree.zones[0].rooms[0].title, "Room")
        XCTAssertEqual(tree.zones[0].rooms[0].devices.map(\.title), ["contact_sensor", "Device"])
    }

    private static let zone = Zone(
        id: 1,
        urn: "urn:zone:1",
        name: "Home",
        rooms: [Room(id: 10, urn: "urn:room:10", name: "Living room")]
    )

    private static let device = Device(
        id: NamiDeviceID(100),
        urn: "urn:device:100",
        name: "Front door",
        type: "contact_sensor",
        roomId: 10
    )
}
