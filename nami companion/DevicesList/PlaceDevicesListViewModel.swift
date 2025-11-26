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
        var placeId: NamiPlaceID
        var bssid: [UInt8]?
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(state: State, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.nextRoute = nextRoute
    }
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private var disposable = Set<AnyCancellable>()
    
    func presentPairing() {
//        nextRoute(.pairing(state.pairingInRoomId, state.devices.isEmpty ? nil : state.bssid))
        nextRoute(.presentSingleDeviceSetup)
    }
    
    func presentPositioning(deviceName: String, deviceUid: NamiDeviceUniversalID) {
//        nextRoute(.positioning(state.pairingInRoomId, state.bssid, deviceName, deviceUid))
    }
    
    func presentSetupGuide() {
        nextRoute(.presentSetupGuide)
    }
    
    func presentSettings() {
        nextRoute(.presentSettings)
    }
    
}
