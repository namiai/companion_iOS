// Copyright (c) nami.ai

import Foundation
import Combine
import SwiftUI
import NamiPairingFramework

// MARK: - PlaceDevicesListViewModel

final class PlaceDevicesListViewModel: ObservableObject {
    enum EmptyPlaceError: Error {
        case noZoneOrRoom
    }
    
    struct State {
        /// External id of the place's managing client, from the session activation.
        var partnerId: String?
        var bssid: [UInt8]?
        var devices: [Device] = []
        /// The place's topology, for naming the entities the mapping points at.
        var place: Place?
        /// The backend's `external id → internal URN` mapping for this place and partner;
        /// `nil` until it loads.
        var externalDeviceIds: [String: String]?
        var isEntityPickerPresented = false
        /// Entity ID typed into the entity picker sheet.
        var manualEntityId = ""
        var offerRetry = false
        var presentingPairing = false

        /// The place's zones, rooms and devices with the mapping keys that point at each.
        ///
        /// `nil` until both the place and the mapping are loaded.
        var entityPickerTree: EntityPickerTree? {
            guard let place, let externalDeviceIds else { return nil }
            return EntityPickerTree(zones: place.zones, devices: devices, mapping: externalDeviceIds)
        }
    }
    
    /// Creates the view model and starts loading the place's devices, topology and mapping.
    ///
    /// - Parameters:
    ///   - pairingManager: The activated session's pairing manager; supplies the token, place id
    ///     and partner id.
    ///   - nextRoute: Called with the route to navigate to.
    init(pairingManager: PairingManager, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = State(partnerId: pairingManager.partnerId)
        self.pairingManager = pairingManager
        self.nextRoute = nextRoute
        
        refreshDevices()
        refreshPlace()
        refreshExternalDeviceIds()
    }
    
    @Published var state: State
    let pairingManager: PairingManager
    let nextRoute: (RootRouter.Routes) -> Void
    private var disposable = Set<AnyCancellable>()
    
    func presentPairing() {
        nextRoute(.presentSingleDeviceSetup)
    }
    
    func presentSetupGuide() {
        nextRoute(.presentSetupGuide)
    }
    
    func presentSettings() {
        nextRoute(.presentSettings)
    }

    /// Opens the entity picker with a fresh place, device list and mapping.
    func presentEntityPicker() {
        state.isEntityPickerPresented = true
        refreshDevices()
        refreshPlace()
        refreshExternalDeviceIds()
    }

    /// Opens settings scoped to a partner entity id.
    ///
    /// - Parameter entityId: A mapping key, or any id typed into the sheet (including ids the
    ///   mapping lacks, to exercise the not-found path).
    func presentSettings(forEntity entityId: String) {
        state.isEntityPickerPresented = false
        nextRoute(.presentSettingsForEntity(entityId: entityId))
    }

    func presentUpdateWiFiCredentials() {
        nextRoute(.presentUpdateWiFiCredentials)
    }

    func presentPinCreation() {
        nextRoute(.presentPinCreation)
    }
    
    func presentSystemCheckup() {
        nextRoute(.presentSystemCheckup)
    }
    
    func presentEntryExitDelays() {
        nextRoute(.presentEntryExitDelays)
    }
    
    func refreshDevices() {
        guard let token = pairingManager.accessToken else { return }
        let placeId = pairingManager.placeId.rawValue
        
        var request = URLRequest(url: URL(string: "\(PairingManager.baseUrl)/devices?place_ids=\(placeId)")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: DevicesResponse.self, decoder: Self.apiDecoder)
            .map { $0.devices.map { Device(id: NamiDeviceID($0.id), urn: $0.urn, name: $0.name, type: $0.model?.codeName, roomId: $0.roomId) } }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Failed to fetch devices: \(error)")
                }
            } receiveValue: { [weak self] devices in
                self?.state.devices = devices
            }
            .store(in: &disposable)
    }
    
    func refreshPlace() {
        guard let token = pairingManager.accessToken else { return }
        let placeId = pairingManager.placeId.rawValue
        
        var request = URLRequest(url: URL(string: "\(PairingManager.baseUrl)/places/\(placeId)")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Place.self, decoder: Self.apiDecoder)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Failed to fetch place: \(error)")
                }
            } receiveValue: { [weak self] place in
                self?.state.place = place
            }
            .store(in: &disposable)
    }
    
    /// Fetches the place's external device id mapping for the session's partner and stores it
    /// for the entity picker. The mapping's keys are the partner ids the SDK can resolve.
    ///
    /// Does nothing when the session has no partner id: there is no mapping to ask for.
    func refreshExternalDeviceIds() {
        guard let token = pairingManager.accessToken, let partnerId = state.partnerId else { return }
        let request = Self.externalDeviceIdsRequest(
            baseUrl: PairingManager.baseUrl,
            placeId: pairingManager.placeId.rawValue,
            partnerId: partnerId,
            accessToken: token
        )

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ExternalDeviceIdsResponse.self, decoder: Self.apiDecoder)
            .map(\.externalDeviceIds)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Failed to fetch external device ids: \(error)")
                }
            } receiveValue: { [weak self] mapping in
                self?.state.externalDeviceIds = mapping
            }
            .store(in: &disposable)
    }

    /// Builds `GET /places/:place_id/external-device-ids?external_client_id=<partner id>`.
    ///
    /// - Parameters:
    ///   - baseUrl: The nami API base URL.
    ///   - placeId: The session's place id.
    ///   - partnerId: The external id of the client whose mapping to fetch.
    ///   - accessToken: The session's bearer token.
    /// - Returns: The authorized request.
    static func externalDeviceIdsRequest(baseUrl: URL, placeId: Int64, partnerId: String, accessToken: String) -> URLRequest {
        let url = baseUrl
            .appending(path: "places/\(placeId)/external-device-ids")
            .appending(queryItems: [URLQueryItem(name: "external_client_id", value: partnerId)])
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func deleteDevice(deviceId: NamiDeviceID) {
        guard let token = pairingManager.accessToken else { return }
        
        var request = URLRequest(url: URL(string: "\(PairingManager.baseUrl)/devices/\(deviceId.rawValue)")!)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.refreshDevices()
                case .failure(let error):
                    print("Failed to delete device: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &disposable)
    }
    
    private static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()
}

// MARK: - API Response Models

private struct DevicesResponse: Decodable {
    let devices: [APIDevice]
}

private struct APIDevice: Decodable {
    let id: Int64
    let urn: String
    let name: String
    let model: APIDeviceModel?
    let roomId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case id, urn, name, model
        case roomId = "room_id"
    }
}

private struct APIDeviceModel: Decodable {
    let codeName: String
    
    enum CodingKeys: String, CodingKey {
        case codeName = "code_name"
    }
}

/// Response of `GET /places/:place_id/external-device-ids`:
/// `{ "external_device_ids": { "<external id>": "<urn>", ... } }`.
struct ExternalDeviceIdsResponse: Decodable {
    /// Every external id the partner has in the place, mapped to the internal URN it resolves to.
    let externalDeviceIds: [String: String]

    enum CodingKeys: String, CodingKey {
        case externalDeviceIds = "external_device_ids"
    }
}

// MARK: - Place Models

struct Place: Decodable {
    let id: Int64
    let urn: String
    let name: String
    let zones: [Zone]
}

struct Zone: Decodable, Identifiable {
    let id: Int64
    let urn: String
    let name: String
    let rooms: [Room]
}

struct Room: Decodable, Identifiable {
    let id: Int64
    let urn: String
    let name: String
}
