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
        var bssid: [UInt8]?
        var devices: [Device] = []
        var place: Place?
        var isEntityPickerPresented = false
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(pairingManager: PairingManager, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = State()
        self.pairingManager = pairingManager
        self.nextRoute = nextRoute
        
        refreshDevices()
        refreshPlace()
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

    func presentSettings(forEntity urn: String) {
        state.isEntityPickerPresented = false
        nextRoute(.presentSettingsForEntity(urn: urn))
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
