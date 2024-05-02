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
        var roomUuid: RoomUUID
        var bssid: [UInt8]?
        var deviceId: DeviceID
        var device: Device?
    }
    
    init(state: State, api: some PairingWebAPIProtocol, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.nextRoute = nextRoute
        self.api = api
        self.updateDevices(api: api)
    }
    
    func updateDevices<API: PairingWebAPIProtocol>(api: API) {
        api.listDevices(query: DeviceQuery())
            .map(\.devices)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(_) = completion {
                    return
                }
            } receiveValue: { [weak self] devices in
                DispatchQueue.main.async {
                    if let fetchedDevice = devices.first(where: { $0.id == self?.state.deviceId}) as? Device {
                        self?.state.device = fetchedDevice
                    }
                }
            }
            .store(in: &disposable)
    }
    
    @Published var state: State
    private let api: any PairingWebAPIProtocol
    let nextRoute: (RootRouter.Routes) -> Void
    private var disposable = Set<AnyCancellable>()
    
    func presentPositioning(deviceName: String, deviceUid: DeviceUniversalID) {
        nextRoute(.positioning(self.state.roomUuid, self.state.bssid, deviceName, deviceUid))
    }
}
