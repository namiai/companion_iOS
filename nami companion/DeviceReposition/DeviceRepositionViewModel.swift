// Copyright (c) nami.ai

import Foundation
import Combine
import NamiPairingFramework

final class DeviceRepositionViewModel: ObservableObject {
    struct State {
        var roomUuid: RoomUUID
        var bssid: [UInt8]?
        var deviceId: NamiDeviceID
        var device: Device?
    }
    
    init(state: State, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.nextRoute = nextRoute
    }
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    
    func presentPositioning(deviceName: String, deviceUid: String) {
        // Positioning is not exposed in the simplified companion API
    }
}
