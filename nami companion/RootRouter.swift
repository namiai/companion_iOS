// Copyright (c) nami.ai

import Foundation
import SwiftUI
import NamiPairingFramework
import Combine

typealias RoomUUID = String

final class RootRouter: ObservableObject {
    enum Routes {
        case codeInput
        case placeDevices([UInt8]?)
        case pairing(RoomUUID, [UInt8]?)
        case deviceReposition(RoomUUID, DeviceID)
        case positioning(RoomUUID, [UInt8]?, String, DeviceUniversalID)
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
        case let .placeDevices(bssid):
            PlaceDevicesListView(viewModel: PlaceDevicesListViewModel(
                state: PlaceDevicesListViewModel.State(placeId: pairingManager!.placeId, bssid: bssid),
                api: pairingManager!.api,
                threadDatasetProvider: pairingManager!.threadDatasetProvider,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .pairing(roomUuid, bssid):
            pairing(roomUuid: roomUuid, bssidPin: bssid)
        case let .deviceReposition(roomUuid, deviceId):
            DeviceRepositionView(viewModel: DeviceRepositionViewModel(
                state: DeviceRepositionViewModel.State(roomUuid: roomUuid, deviceId: deviceId), api: pairingManager!.api,
                nextRoute: { route in
                    self.route = route
                })
            )
        case let .positioning(roomUuid, bssid, deviceName, deviceUid):
            positioning(roomUuid: roomUuid, bssid: bssid, deviceName: deviceName, deviceUid: deviceUid.macFormatted)
        case .presentSingleDeviceSetup:
            presentSingleDeviceSetup()
        case .presentSetupGuide:
            presentSetupGuide()
        case .presentSettings:
            presentSettings()
        }
    }
    
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
                        self?.route = .placeDevices(bssid)
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
                    self.route = .placeDevices(bssid)
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
        Log.info("[SDK Tester Root Router] got Setup Guide event: \(event)")
        switch event {
        case .cancel:
            DispatchQueue.main.async {
                self.route = .placeDevices(nil)
            }
        case .startPairing(roomId: let roomId):
            (self.pairingManager!.api as? WebAPI)?.listPlaceZones(for: self.pairingManager!.placeId)
                .compactMap { zones in
                    zones.flatMap(\.rooms).first { room in
                        room.id == roomId
                    }?.externalId
                }
                .sink { _ in } receiveValue: { roomUuid in
                    DispatchQueue.main.async {
                        self.route = .pairing(roomUuid, nil)
                    }
                }
                .store(in: &cancellables)
        case .error(let error):
            Log.warning("[Setup Guide] some error occurred: \(error.localizedDescription)")
            break
//            self.currentError = NamiError(error)
        }
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
    
    func clearError() {
        currentError = nil
        if let currentRoomUUID = self.currentRoomUUID {
            self.route = .placeDevices(nil)
        } else {
            self.route = .codeInput
        }
    }
}
