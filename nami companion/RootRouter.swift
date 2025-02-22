// Copyright (c) nami.ai

import Foundation
import SwiftUI
import Combine
import NamiPairingFramework

typealias RoomUUID = String

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices(RoomUUID, [UInt8]?)
        case pairing(RoomUUID, [UInt8]?)
        case deviceReposition(RoomUUID, DeviceID)
        case positioning(RoomUUID, [UInt8]?, String, DeviceUniversalID)
    }
    
    @Published var route = Routes.codeInput
    @Published var currentError: NamiError?
    
    var pairingManager: PairingManager? {
        didSet {
            subscribeToPairingManagerErrors()
        }
    }
    
    var currentRoomUUID: RoomUUID?
    
    @ViewBuilder
    func buildView() -> some View {
        switch route {
        case .codeInput:
            SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                self.pairingManager = pairingManager
            }, nextRoute: { route in
                self.route = route
            }))
        case let .placeDevices(roomId, bssid):
            if let api = pairingManager?.api {
                PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                    state: PlaceDevicesListViewModel.State(pairingInRoomId: roomId, bssid: bssid),
                    api: api,
                    nextRoute: { route in
                        self.route = route
                    })
                )
            } else {
                SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                    self.pairingManager = pairingManager
                }, nextRoute: { route in
                    self.route = route
                }))
            }
        case let .pairing(roomUuid, bssid):
            pairing(roomUuid: roomUuid, bssidPin: bssid)
        case let .deviceReposition(roomUuid, deviceId):
            if let api = pairingManager?.api {
                DeviceRepositionView(viewModel: DeviceRepositionViewModel(
                    state: DeviceRepositionViewModel.State(roomUuid: roomUuid, deviceId: deviceId), api: api, 
                    nextRoute: { route in
                        self.route = route
                    })
                )
            } else {
                SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                    self.pairingManager = pairingManager
                }, nextRoute: { route in
                    self.route = route
                }))
            }
        case let .positioning(roomUuid, bssid, deviceName, deviceUid):
            positioning(roomUuid: roomUuid, bssid: bssid, deviceName: deviceName, deviceUid: deviceUid.macFormatted)
        }
    }
    
    func clearError() {
        currentError = nil
        if let currentRoomUUID = self.currentRoomUUID {
            self.route = .placeDevices(currentRoomUUID, nil)
        } else {
            self.route = .codeInput
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func pairing(roomUuid: RoomUUID, bssidPin: [UInt8]?) -> some View {
        NavigationView {
            pairingManager!.startPairing(roomId: roomUuid, bssidPin: bssidPin) { [weak self] bssid, deviceId, repositionNeeded in
                if repositionNeeded == true, let deviceId = deviceId {
                    DispatchQueue.main.async {
                        self?.route = .deviceReposition(roomUuid, deviceId)
                    }
                } else {
                    Log.info("Closure on complete pairing called")
                    DispatchQueue.main.async {
                        self?.route = .placeDevices(roomUuid, bssid)
                    }    
                }
                
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func positioning(roomUuid: RoomUUID, bssid: [UInt8]?, deviceName: String, deviceUid: String) -> some View {
        NavigationView {
            pairingManager!.startPositioning(deviceName: deviceName, deviceUid: deviceUid) { 
                DispatchQueue.main.async {
                    self.route = .placeDevices(roomUuid, bssid)
                }  
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func subscribeToPairingManagerErrors() {
        pairingManager?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                Log.warning("[RootRouter] Error received: \(error.localizedDescription)")
                if self?.currentError == nil {
                    self?.currentError = NamiError(error)
                }
            }
            .store(in: &cancellables)
    }
}
