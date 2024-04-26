//
//  Router.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import SwiftUI
import NamiPairingFramework

typealias RoomUUID = String

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices(RoomUUID, [UInt8]?)
        case pairing(RoomUUID, [UInt8]?)
        case deviceReposition(String, DeviceUniversalID)
        case positioning(String, DeviceUniversalID)
        case errorView(Error)
    }
    
    @Published var route = Routes.codeInput
    var pairingManager: PairingManager?
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
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(pairingInRoomId: roomId, bssid: bssid),
                api: pairingManager!.api,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .pairing(roomUuid, bssid):
            pairing(roomUuid: roomUuid, bssidPin: bssid)
        case let .deviceReposition(deviceName, deviceUid):
            DeviceRepositionView(viewModel: DeviceRepositionViewModel(
                state: DeviceRepositionViewModel.State(deviceName: deviceName, deviceUid: deviceUid), 
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .positioning(deviceName, deviceUid):
            positioning(deviceName: deviceName, deviceUid: deviceUid.macFormatted)
        case let .errorView(error):
            ErrorPresentationView(viewModel: ErrorPresentationViewModel(
                state: ErrorPresentationViewModel.State(error: error),
                nextRoute: { route in
                    self.route = route
                })
            )
        }
    }
    
    private func pairing(roomUuid: RoomUUID, bssidPin: [UInt8]?) -> some View {
        NavigationView {
            pairingManager!.startPairing(roomId: roomUuid, bssidPin: bssidPin) { [weak self] bssid, repositionNeeded, deviceName, deviceUid in
                if repositionNeeded == true, let deviceName = deviceName, let deviceUid = deviceUid {
                    DispatchQueue.main.async {
                        self?.route = .deviceReposition(deviceName, deviceUid)
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
    
    private func positioning(deviceName: String, deviceUid: String) -> some View {
        NavigationView {
            pairingManager!.startPositioning(deviceName: deviceName, deviceUid: deviceUid) { 
                // it should dismiss itself
            }
        }
        .navigationViewStyle(.stack)
    }
}
