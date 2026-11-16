// Copyright (c) nami.ai

import Foundation

/// The loaded place's zones, rooms and devices, each listing the partner ids that the backend's
/// `external-device-ids` mapping (`external id → internal URN`) points at it.
///
/// Every mapping key stays pickable: keys whose URN matches no node in the tree, for example
/// because the place or device list is stale, are kept in `unmatched`.
struct EntityPickerTree: Equatable {
    /// A mapping key and the internal URN the backend maps it to.
    struct ExternalID: Equatable, Identifiable {
        let externalId: String
        let urn: String
        var id: String { externalId }
    }

    /// A device and the mapping keys that point at its URN.
    struct DeviceNode: Equatable, Identifiable {
        let urn: String
        let title: String
        let externalIds: [ExternalID]
        var id: String { urn }
    }

    /// A room, its devices, and the mapping keys that point at its URN.
    struct RoomNode: Equatable, Identifiable {
        let urn: String
        let title: String
        let externalIds: [ExternalID]
        let devices: [DeviceNode]
        var id: String { urn }
    }

    /// A zone, its rooms, and the mapping keys that point at its URN.
    struct ZoneNode: Equatable, Identifiable {
        let urn: String
        let title: String
        let externalIds: [ExternalID]
        let rooms: [RoomNode]
        var id: String { urn }
    }

    let zones: [ZoneNode]
    /// Mapping keys whose URN is not any zone, room or device in `zones`, sorted by key.
    let unmatched: [ExternalID]

    /// Builds the tree in topology order and attaches mapping keys by exact URN equality.
    ///
    /// - Parameters:
    ///   - zones: The place's zones with their rooms.
    ///   - devices: The place's devices; each is listed under the room with its `roomId`.
    ///     Devices without a room in `zones` are not listed, so their keys land in `unmatched`.
    ///   - mapping: The backend's `external id → internal URN` mapping for the place.
    init(zones: [Zone], devices: [Device], mapping: [String: String]) {
        let keysByUrn = Dictionary(grouping: mapping.map { ExternalID(externalId: $0.key, urn: $0.value) }, by: \.urn)
            .mapValues { $0.sorted { $0.externalId < $1.externalId } }

        let zoneNodes = zones.map { zone in
            ZoneNode(
                urn: zone.urn,
                title: zone.name.isEmpty ? "Zone" : zone.name,
                externalIds: keysByUrn[zone.urn] ?? [],
                rooms: zone.rooms.map { room in
                    RoomNode(
                        urn: room.urn,
                        title: room.name.isEmpty ? "Room" : room.name,
                        externalIds: keysByUrn[room.urn] ?? [],
                        devices: devices.filter { $0.roomId == room.id }.map { device in
                            DeviceNode(
                                urn: device.urn,
                                title: device.name.isEmpty ? (device.type ?? "Device") : device.name,
                                externalIds: keysByUrn[device.urn] ?? []
                            )
                        }
                    )
                }
            )
        }

        let treeUrns = Set(zoneNodes.flatMap { zone in
            [zone.urn] + zone.rooms.flatMap { room in [room.urn] + room.devices.map(\.urn) }
        })

        self.zones = zoneNodes
        self.unmatched = keysByUrn
            .filter { treeUrns.contains($0.key) == false }
            .flatMap(\.value)
            .sorted { $0.externalId < $1.externalId }
    }
}
