//
//  Router.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import SwiftUI
import WebAPI
import CommonTypes

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices(Place, PlaceZoneID, RoomID)
        case errorView(Error)
    }
    
    init(_ services: ApplicationServices) {
        self.services = services
    }
    
    @Published var route = Routes.codeInput
    var services: ApplicationServices
    
    @ViewBuilder
    func buildView() -> some View {
        switch route {
        case .codeInput:
            SessionCodeView(viewModel: SessionCodeViewModel(services: self.services) { route in
                self.route = route
            })
        case let .placeDevices(place, zoneId, roomId):
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(place: place, zoneId: zoneId, roomId: roomId),
                api: services.api!,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .errorView(error):
            ErrorPresentationView(viewModel: ErrorPresentationViewModel(
                state: ErrorPresentationViewModel.State(error: error),
                nextRoute: { route in
                    self.route = route
                })
            )
        }
    }
}
