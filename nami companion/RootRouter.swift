//
//  Router.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import SwiftUI
import NamiStandardPairingFramework

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices(Place)
        case pairing(Place, PlaceZoneID, RoomID)
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
        case let .pairing(place, zoneId, roomId):
            pairing(place: place, zoneId: zoneId, roomId: roomId)
        case let .errorView(error):
            ErrorPresentationView(viewModel: ErrorPresentationViewModel(
                state: ErrorPresentationViewModel.State(error: error),
                nextRoute: { route in
                    self.route = route
                })
            )
        }
    }
    
    private func pairing(place: Place, zoneId: PlaceZoneID, roomId: RoomID) -> some View {
        NavigationView {
            pairingManager!.startPairing(placeId: place.id, zoneId: zoneId, roomId: roomId) { [weak self] in
                Log.info("Closure on complete pairing called")
                DispatchQueue.main.async {
                    self?.route = .placeDevices(place)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
