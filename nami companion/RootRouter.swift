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
        case presentSettingsForEntity(urn: String)
        case presentPinCreation
        case presentSystemCheckup
        case presentEntryExitDelays
        case presentUpdateWiFiCredentials
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
    func buildView() -> some View {
        switch route {
        case .codeInput:
            return SessionCodeView(viewModel: SessionCodeViewModel(setupPairingManager: { pairingManager in
                self.pairingManager = pairingManager
            }, nextRoute: { route in
                DispatchQueue.main.async {
                    self.route = route
                }
            }))
            .anyView
        case .placeDevices:
            return PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                pairingManager: pairingManager!,
                nextRoute: { route in
                    DispatchQueue.main.async {
                        self.route = route
                    }
                })
            )
            .anyView
        case .presentSingleDeviceSetup:
            return presentSingleDeviceSetup()
                .anyView
        case .presentSetupGuide:
            return presentSetupGuide()
                .anyView
        case .presentSettings:
            return presentSettings()
                .anyView
        case let .presentSettingsForEntity(urn):
            return presentSettingsForEntity(urn: urn)
                .anyView
        case .presentPinCreation:
            return presentPinCreation()
                .anyView
        case .presentSystemCheckup:
            return presentSystemCheckup()
                .anyView
        case .presentEntryExitDelays:
            return presentEntryExitDelaySettings()
                .anyView
        case .presentUpdateWiFiCredentials:
            return presentUpdateWiFiCredentials()
                .anyView
        }
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

    @MainActor
    private func presentSettingsForEntity(urn: String) -> some View {
        NavigationView {
            pairingManager!.presentSettingsForEntity(urn: urn) { [weak self] event in
                self?.onGuideEnded(event: event)
            }
        }
        .navigationViewStyle(.stack)
    }

    @MainActor
    private func presentPinCreation() -> some View {
        pairingManager!.presentPinCreation { [weak self] event in
            self?.onGuideEnded(event: event)
        }
    }
    
    @MainActor
    private func presentSystemCheckup() -> some View {
        pairingManager!.presentSystemCheckup { [weak self] event in
            self?.onGuideEnded(event: event)
        }
    }
    
    @MainActor
    private func presentEntryExitDelaySettings() -> some View {
        pairingManager!.presentEntryExitDelaySettings { [weak self] event in
            self?.onGuideEnded(event: event)
        }
    }

    @MainActor
    private func presentUpdateWiFiCredentials() -> some View {
        pairingManager!.presentUpdateWiFiCredentials { [weak self] event in
            self?.onGuideEnded(event: event)
        }
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
        if self.currentRoomUUID != nil {
            self.route = .placeDevices
        } else {
            self.route = .codeInput
        }
    }
}

extension View {
    var anyView: AnyView {
        AnyView(self)
    }
}
