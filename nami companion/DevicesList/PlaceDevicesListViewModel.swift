// Copyright (c) nami.ai

import Foundation
import Combine
import SwiftUI
import NamiPairingFramework
import WebAPI

// MARK: - PlaceDevicesListViewModel

final class PlaceDevicesListViewModel: ObservableObject {
    enum EmptyPlaceError: Error {
        case noZoneOrRoom
    }
    
    struct State {
        var placeId: NamiPlaceID
        var bssid: [UInt8]?
        var offerRetry = false
        var presentingPairing = false
        var devices: [Device] = []
    }
    
    init(state: State, api: WebAPI, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.api = api
        self.nextRoute = nextRoute
        
        api.listDevices(query: .parameters(placeIds: [state.placeId].map(\.rawValue)))
            .map(\.devices)
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
    
    @Published var state: State
    let api: WebAPI
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
    
}
