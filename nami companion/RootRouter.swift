// Copyright (c) nami.ai

import Foundation
import SwiftUI
import NamiPairingFramework
import Combine


typealias RoomUUID = String

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices
        case presentSingleDeviceSetup
        case presentSetupGuide
        case presentSettings
    }
    
    @Published var route = Routes.codeInput
    @Published var currentError: NamiError?
    var pairingManager: PairingManager? {
        didSet {
            subscribeToPairingManagerErrors()
        }
    }
    var currentRoomUUID: RoomUUID?
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    @ViewBuilder
    func buildView() -> some View {
        switch route {
        case .codeInput:
            SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                self.pairingManager = pairingManager 
            }, nextRoute: { route in
                self.route = route
            }))
        case .placeDevices:
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(placeId: pairingManager!.placeId),
                nextRoute: { route in
                    self.route = route
                })
            )
        case .presentSingleDeviceSetup:
            presentSingleDeviceSetup()
        case .presentSetupGuide: 
            presentSetupGuide()
        case .presentSettings:
            presentSettings()
        }
    }
    
    private func positioning(roomUuid: RoomUUID, bssid: [UInt8]?, deviceName: String, deviceUid: String) -> some View {
        NavigationView {
            pairingManager!.startPositioning(deviceName: deviceName, deviceUid: deviceUid) { 
                DispatchQueue.main.async {
                    self.route = .placeDevices
                }  
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @MainActor
    private func presentSingleDeviceSetup() -> some View {
        NavigationView {
            pairingManager!.presentSingleDeviceSetup{ [weak self] event in
                self?.onGuideEnded(event: event)
            }
        }
    }
    
    @MainActor
    private func presentSetupGuide() -> some View {
        NavigationView {
            pairingManager!.presentSetupGuide{ [weak self] event in
                self?.onGuideEnded(event: event)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @MainActor
    private func presentSettings() -> some View {
        NavigationView {
            pairingManager!.presentSettings { [weak self] event in
                self?.onGuideEnded(event: event)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func onGuideEnded(event: PairingManager.GuideAction) {
        print("[SDK Tester Root Router] got Setup Guide event: \(event)")
        switch event {
        case .cancel:
            DispatchQueue.main.async {
                self.route = .placeDevices
            }
        case .error(let error):
            print("[Setup Guide] some error occurred: \(error.localizedDescription)")
            break
        }
    }

    private func subscribeToPairingManagerErrors() {
        pairingManager?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                print("[RootRouter] Error received: \(error.localizedDescription)")
                if self?.currentError == nil {
                    self?.currentError = NamiError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    func clearError() {
        currentError = nil
        if let currentRoomUUID = self.currentRoomUUID {
            self.route = .placeDevices
        } else {
            self.route = .codeInput
        }
    }
}
