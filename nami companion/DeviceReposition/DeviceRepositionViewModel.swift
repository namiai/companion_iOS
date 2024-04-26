//
//  DeviceRepositionViewModel.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 26/4/24.
//

import Foundation
import Combine
import NamiPairingFramework

final class DeviceRepositionViewModel: ObservableObject {
    struct State {
        var deviceName: String
        var deviceUid: DeviceUniversalID
    }
    
    init(state: State, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.nextRoute = nextRoute
    }
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private var disposable = Set<AnyCancellable>()
    
    func presentPositioning(deviceName: String, deviceUid: DeviceUniversalID) {
        nextRoute(.positioning(deviceName, deviceUid))
    }
}
