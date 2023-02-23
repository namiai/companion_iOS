// Copyright (c) nami.ai

import Combine
import CommonTypes
import Foundation
import Log
import NamiStandardPairingSDK
import SwiftUI
import WebAPI
import WiFiStorage

final class PairingManager {
    // MARK: Lifecycle
    
    init(
        api: WebAPIProtocol,
        wifiStorage: WiFiStorageProtocol,
        onGetDevice: @escaping (Device) -> Void,
        onDeleteDevice: @escaping (DeviceID) -> Void
    ) {
        pairingSdk = NamiStandardPairingSDK(api: api, wifiStorage: wifiStorage)
        self.onGetDevice = onGetDevice
        self.onDeleteDevice = onDeleteDevice
        setupSubscription(api: api, wifiStorage: wifiStorage)
    }
    
    // MARK: Internal
    
    func startPairing(
        placeId: PlaceID,
        zoneId: PlaceZoneID,
        roomId: RoomID,
        onPairingComplete: (() -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        return pairingSdk.startPairing(placeId: placeId, zoneId: zoneId, roomId: roomId)
    }
    
    // MARK: Private
    
    private var pairingSdk: NamiStandardPairingSDK
    private var subscriptions = Set<AnyCancellable>()
    private var onPairingComplete: (() -> Void)?
    private var onGetDevice: (Device) -> Void
    private var onDeleteDevice: (DeviceID) -> Void
    
    private func setupSubscription(
        api: WebAPIProtocol,
        wifiStorage: WiFiStorageProtocol
    ) {
        pairingSdk.devicePairingState
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.warning("[PairingManager] Device state publisher failed with error: \(error.localizedDescription)")
                }
                guard let self else { return }
                self.completePairing()
                self.pairingSdk = NamiStandardPairingSDK(api: api, wifiStorage: wifiStorage)
                self.setupSubscription(api: api, wifiStorage: wifiStorage)
            } receiveValue: { [weak self] deviceState in
                switch deviceState {
                case let .deviceCommisionedAtCloud(device, in: _):
                    self?.onGetDevice(device)
                case .deviceOperable:
                    self?.completePairing()
                case let .deviceDecommissioned(deviceId):
                    self?.onDeleteDevice(deviceId)
                    self?.completePairing()
                case .pairingCancelled:
                    self?.completePairing()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func completePairing() {
        onPairingComplete?()
        onPairingComplete = nil
    }
}
