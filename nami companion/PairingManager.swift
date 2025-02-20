// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import StandardPairingUI
import SwiftUI

final class PairingManager {
    public var errorPublisher = PassthroughSubject<Error, Never>()
    
    // MARK: Lifecycle

    init?(sessionCode: String, onError: ((CompanionError) -> Void)? = nil) {
        self.onError = onError

        do {
            // Initialize pairing inside the do block after the stored properties are set
            // Using built in SDK's WiFi Storage and Thread Dataset Store, data stored are only available in one session
            // self.pairing = try NamiPairing<ViewsContainer>(sessionCode: sessionCode, wifiStorage: InMemoryWiFiStorage(), threadDatasetStore: InMemoryThreadDatasetStorage.self)
            
            self.pairing = try NamiPairing<ViewsContainer>(
                sessionCode: sessionCode, 
                wifiStorage: KeychainWiFiStorage(), 
                threadDatasetStore: KeychainThreadDatasetStorage.self, 
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    Log.warning("[PairingManager] Error occurred: \(error.localizedDescription)")
                    self.errorPublisher.send(error)
                    self.onError?(CompanionError(error: error, detailedMessage: error.localizedDescription))
                }
            )
            setupSubscription()
        } catch {
            self.onError?(handleError(error))
        }
    }

    // MARK: Internal

    func startPairing(
        roomId: String,
        bssidPin: [UInt8]?,
        onPairingComplete: (([UInt8]?, DeviceID?, Bool?) -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        do {
            return try AnyView(
                pairing?.startPairing(
                    roomId: roomId,
                    pairingSteps: ViewsContainer(),
                    pairingParameters: bssidPin == nil ? NamiPairing.PairingParameters() : NamiPairing.PairingParameters(bssid: bssidPin!)
                )
            )
        } catch {
            self.onError?(handleError(error))
            return AnyView(
                VStack {
                    Text("The Room ID provided could not be found in the Place topology.")
                    Button("Back to Place") {
                        self.completePairing()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            )
        }
    }

    func startPositioning(deviceName: String, deviceUid: String, onPositioningComplete: (() -> Void)? = nil) -> some View {
        self.onPositioningComplete = onPositioningComplete
        do {
            return try AnyView(
                pairing?.startPositioning(
                    deviceName: deviceName,
                    deviceUid: deviceUid,
                    pairingSteps: ViewsContainer(),
                    onPositioningEnded: { result in
                        self.completePositioning()
                    })
            )
        } catch {
            self.onError?(handleError(error))
            return AnyView(
                VStack {
                    Text("The Device name or UID provided could not be found.")
                    Button("Back to Place") {
                        self.completePositioning()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            )
        }
    }

    // MARK: Private

    private var pairing: NamiPairing<ViewsContainer>? // Make optional to allow initialization inside init
    private var subscriptions = Set<AnyCancellable>()
    private var device: Device?
    private var onPairingComplete: (([UInt8]?, DeviceID?, Bool?) -> Void)?
    private var onPositioningComplete: (() -> Void)?
    private var onError: ((CompanionError) -> Void)?

    var api: (any PairingWebAPIProtocol)? {
        pairing?.api
    }

    private func setupSubscription() {
        pairing?.devicePairingState
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    if let error = self?.handleError(error) {
                        self?.onError?(error)
                    }
                }
                self?.completePairing()
            } receiveValue: { [weak self] deviceState in
                Log.info("[PairingManager] got device state \(deviceState)")
                switch deviceState {
                case .deviceCommisionedAtCloud(let device, in: _):
                    self?.device = device as? Device
                case .deviceOperable(let deviceId, _, ssid: _, bssid: let bssid, positionAdjustmentNeeded: let repositionNeeded):
                    if repositionNeeded == true {
                        self?.completePairing(bssid: bssid, deviceId: deviceId, repositionNeeded: repositionNeeded)
                    } else {
                        self?.completePairing(bssid: bssid)
                    }
                case .deviceDecommissioned:
                    self?.completePairing()
                case .pairingCancelled:
                    self?.completePairing()
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
    }

    private func handleError(_ error: Error) -> CompanionError {
        if let e = error as? NetworkError {
            let message = "[Pairing init] Network Error: \(e.localizedDescription)"
            Log.warning(message)
            return CompanionError(error: e, detailedMessage: message)
        } else if let e = error as? SDKError {
            switch e {
            case let .sessionActivateMalformedResponse(data):
                let message = "[Pairing init] SDK Error: \(e.localizedDescription), containing unparsed data: \(String(data: data, encoding: .utf8) ?? "failed to encode into utf8 string")"
                Log.warning(message)
                return CompanionError(error: e, detailedMessage: message)
            default:
                let message = "[Pairing init] SDK Error: \(e.localizedDescription)"
                Log.warning(message)
                return CompanionError(error: e, detailedMessage: message)
            }
        } else {
            let message = "[Pairing init] Unknown Error: \(error.localizedDescription)"
            Log.warning(message)
            return CompanionError(error: error, detailedMessage: message)
        }
    }
    
    private func completePairing(bssid: [UInt8]? = nil, deviceId: DeviceID? = nil, repositionNeeded: Bool? = nil) {
        onPairingComplete?(bssid, deviceId, repositionNeeded)
        onPairingComplete = nil
    }

    private func completePositioning() {
        onPositioningComplete?()
        onPositioningComplete = nil
    }
}
