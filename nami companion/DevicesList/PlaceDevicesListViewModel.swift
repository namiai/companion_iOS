// Copyright (c) nami.ai

import Foundation
import Combine
import SwiftUI
import NamiPairingFramework

final class PlaceDevicesListViewModel: ObservableObject {
    enum EmptyPlaceError: Error {
        case noZoneOrRoom
    }
    
    struct State {
        var pairingInRoomId: String
        var bssid: [UInt8]?
        var devices: [any DeviceProtocol] = []
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(state: State, api: some PairingWebAPIProtocol, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.api = api
        self.nextRoute = nextRoute
        self.updateDevices(api: api)
    }
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private let api: any PairingWebAPIProtocol
    private var disposable = Set<AnyCancellable>()
    
    func updateDevices<API: PairingWebAPIProtocol>(api: API) {
        api.listDevices(query: DeviceQuery())
            .map(\.devices)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(_) = completion {
                    DispatchQueue.main.async {
                        self.state.offerRetry = true
                    }
                    return
                }
            } receiveValue: { [weak self] devices in
                DispatchQueue.main.async {
                    self?.state.devices = devices
                    self?.state.offerRetry = false
                }
            }
            .store(in: &disposable)
    }
    
    func presentPairing() {
        nextRoute(.pairing(state.pairingInRoomId, state.bssid))
    }
    
    func presentPositioning(deviceName: String, deviceUid: DeviceUniversalID) {
        nextRoute(.positioning(state.pairingInRoomId, state.bssid, deviceName, deviceUid))
    }
    
    func deleteDevice(deviceId: DeviceID) {
        api.deleteDevice(id: deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    // Handle successful completion
                    self.updateDevices(api: self.api)
                case .failure(let error):
                    // Handle failure
                    print("Failed to delete device: \(error)")
                    // Optionally, you can show an alert or perform any other error handling here
                }
            }, receiveValue: { _ in
                // Do nothing here since we are only interested in completion events
            })
            .store(in: &disposable)
    }
}

struct DeviceQuery: DevicesQueryProtocol {
    
    init(placeIds: [PlaceID] = [], zoneIds: [PlaceZoneID] = [], roomIds: [RoomID] = [], uids: [DeviceUniversalID] = []) {
        self.placeIds = placeIds
        self.zoneIds = zoneIds
        self.roomIds = roomIds
        self.uids = uids
    }
    
    init(cursor: String) {
        self.placeIds = []
        self.zoneIds = []
        self.roomIds = []
        self.uids = []
        self.cursor = cursor
    }
    
    var placeIds: [PlaceID]
    var zoneIds: [PlaceZoneID]
    var roomIds: [RoomID]
    var uids: [NamiPairingFramework.DeviceUniversalID]
    var cursor: String?
}
