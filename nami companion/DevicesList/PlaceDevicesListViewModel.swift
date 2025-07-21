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
        var placeId: PlaceID
        var bssid: [UInt8]?
        var devices: [Device] = []
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(state: State, api: some PairingWebAPIProtocol, threadDatasetProvider: some PairingThreadOperationalDatasetProviderProtocol, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.api = api
        self.threadDatasetProvider = threadDatasetProvider
        self.nextRoute = nextRoute
        self.updateDevices(api: api)
    }
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private let api: any PairingWebAPIProtocol
    private let threadDatasetProvider: any PairingThreadOperationalDatasetProviderProtocol
    private var disposable = Set<AnyCancellable>()
    
    func updateDevices<API: PairingWebAPIProtocol>(api: API) {
        api.listDevices(query: NamiDevicesQuery(placeIds: [self.state.placeId]))
            .map(\.devices)
            .map { $0.map(Device.init) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self, case .failure = completion else { return }
                    self.state.offerRetry = true
                },
                receiveValue: { [weak self] devices in
                    self?.state.devices = devices
                    self?.state.offerRetry = false
                }
            )
            .store(in: &disposable)
    }
    
    func presentPairing() {
//        nextRoute(.pairing(state.pairingInRoomId, state.devices.isEmpty ? nil : state.bssid))
        nextRoute(.presentSingleDeviceSetup)
    }
    
    func presentPositioning(deviceName: String, deviceUid: DeviceUniversalID) {
//        nextRoute(.positioning(state.pairingInRoomId, state.bssid, deviceName, deviceUid))
    }
    
    func presentSetupGuide() {
        nextRoute(.presentSetupGuide)
    }
    
    func presentSettings() {
        nextRoute(.presentSettings)
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
    
    func deleteThreadCredentials() {        
        threadDatasetProvider.removeDataset(for: state.placeId)
    }
}
