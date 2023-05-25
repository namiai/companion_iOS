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
        case placeDevices(RoomUUID)
        case pairing(RoomUUID)
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
        case let .placeDevices(roomId):
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(pairingInRoomId: roomId),
                api: pairingManager!.api,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .pairing(roomUuid):
            pairing(roomUuid: roomUuid)
        case let .errorView(error):
            ErrorPresentationView(viewModel: ErrorPresentationViewModel(
                state: ErrorPresentationViewModel.State(error: error),
                nextRoute: { route in
                    self.route = route
                })
            )
        }
    }
    
    private func pairing(roomUuid: RoomUUID) -> some View {
        NavigationView {
            pairingManager!.startPairing(roomId: roomUuid) { [weak self] in
                Log.info("Closure on complete pairing called")
                DispatchQueue.main.async {
                    self?.route = .placeDevices(roomUuid)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
