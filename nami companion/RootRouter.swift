//
//  Router.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import SwiftUI
import NamiStandardPairingFramework

typealias ZoneUUID = String
typealias RoomUUID = String

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices(Place)
        case pairing(Place, ZoneUUID, RoomUUID)
        case errorView(Error)
    }
    
    @Published var route = Routes.codeInput
    var pairingManager: PairingManager?
    
    @ViewBuilder
    func buildView() -> some View {
        switch route {
        case .codeInput:
            SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                self.pairingManager = pairingManager
            }, nextRoute: { route in
                self.route = route
            }))
        case let .placeDevices(place):
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(place: place),
                api: pairingManager!.api,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .pairing(place, zoneUuid, roomUuid):
            pairing(place: place, zoneUuid: zoneUuid, roomUuid: roomUuid)
        case let .errorView(error):
            ErrorPresentationView(viewModel: ErrorPresentationViewModel(
                state: ErrorPresentationViewModel.State(error: error),
                nextRoute: { route in
                    self.route = route
                })
            )
        }
    }
    
    private func pairing(place: Place, zoneUuid: ZoneUUID, roomUuid: RoomUUID) -> some View {
        NavigationView {
            pairingManager!.startPairing(zoneUuid: zoneUuid, roomUuid: roomUuid) { [weak self] in
                Log.info("Closure on complete pairing called")
                DispatchQueue.main.async {
                    self?.route = .placeDevices(place)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
