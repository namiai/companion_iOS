// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import StandardPairingUI
import SwiftUI

final class PairingManager {
    // MARK: Lifecycle
    
    init(sessionCode: String) throws {
        do {
            // This init is called passing all the parameters, but the same defaults for `wifiStorage` and `threadDatasetStore` would be set implicitly.
            // Could be initialized as `try NamiPairing<ViewsContainer>(sessionCode: sessionCode)`.
            pairing = try NamiPairing<ViewsContainer>(sessionCode: sessionCode, wifiStorage: InMemoryWiFiStorage(), threadDatasetStore: InMemoryThreadDatasetStorage.self)
            setupSubscription()
        } catch {
            if let e = error as? NetworkError {
                Log.warning("[Pairing init] Network Error: \(e.localizedDescription)")
            }
            if let e = error as? NamiPairing<ViewsContainer>.SDKError {
                switch e {
                case let .sessionActivateMalformedResponse(data):
                    Log.warning("[Pairing init] SDK Error: \(e.localizedDescription), containing unparsed data: \(String(data: data, encoding: .utf8) ?? "failed to encode into utf8 string")")
                    throw error
                default:
                    Log.warning("[Pairing init] SDK Error: \(e.localizedDescription)")
                    throw error
                }
            }
            Log.warning("[Pairing init] SDK Error: \(error.localizedDescription)")
            throw error
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
                pairing.startPairing(
                    roomId: roomId,
                    // Use ViewsContainer() for default nami views 
                    pairingSteps: ViewsContainer(),
                    // Plaese notice the BSSID pin is passed here to limit the WIFi networks search.
                    // Here it is in form of `[UInt8]` but also could be `Data` or ":"-separated MAC-formatted `String`.
                    pairingParameters: bssidPin == nil ? NamiPairing.PairingParameters() : NamiPairing.PairingParameters(bssid: bssidPin!)
                )
            )
        } catch {
            return AnyView(
                VStack{
                    Text("The Room ID provided could not be found in the Place topology.")
                    Button("Back to Place") {
                        self.completePairing()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                })
        }
    }
    
    func startPositioning(deviceName: String, deviceUid: String, onPositioningComplete: (() -> Void)? = nil) -> some View {
        self.onPositioningComplete = onPositioningComplete
        do {
            return try AnyView(
                pairing.startPositioning(
                    deviceName: deviceName, 
                    deviceUid: deviceUid, 
                    pairingSteps: ViewsContainer(), 
                    onPositioningEnded: { result in 
                        self.completePositioning()
                    })
            )
        } catch {
            return AnyView(
                VStack{
                    Text("The Device name or UID provided could not be found in.")
                    Button("Back to Place") {
                        self.completePositioning()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                })
        }
    }
    
    // MARK: Private
    
    private var pairing: NamiPairing<ViewsContainer>
    private var subscriptions = Set<AnyCancellable>()
    private var device: Device?
    private var onPairingComplete: (([UInt8]?, DeviceID?, Bool?) -> Void)?
    private var onPositioningComplete: (() -> Void)?
    
    var api: any PairingWebAPIProtocol {
        pairing.api
    }
    
    private func setupSubscription() {
        pairing.devicePairingState
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.warning("[PairingManager] Device state publisher failed with error: \(error.localizedDescription)")
                }
                guard let self else { return }
                self.completePairing()
            } receiveValue: { [weak self] deviceState in
                Log.info("[PairingManager] got device state \(deviceState)")
                switch deviceState {
                case .deviceCommisionedAtCloud(let device, in: _):
                    // Here the associated values might be obtained for case:
                    // `.deviceCommisionedAtCloud(device, in: placeId)`.
                    // For this demo we don't store device but would later obtain it from API.
                    // The pairing is not over yet.
                    self?.device = device as? Device
                    break
                case .deviceOperable(let deviceId, ssid: _, bssid: let bssid, positionAdjustmentNeeded: let repositionNeeded):
                    // Device is fully commisioned.
                    // Values with device ID, network SSID and BSSID pin could be obtained `.deviceOperable(deviceId, ssid: ssid, bssid: bssid)`.
                    if repositionNeeded == true {
                        self?.completePairing(bssid: bssid, deviceId: deviceId, repositionNeeded: repositionNeeded)
                        break
                    }
                    self?.completePairing(bssid: bssid)
                case .deviceDecommissioned:
                    // Pairing was cancelled/errored unrecoverably after commisioning the Device in nami cloud.
                    // Value with device ID could be obtained `.deviceDecommissioned(deviceId)`
                    // to revert the actions the SDK consumer might took
                    // after getting the device on `.deviceCommisionedAtCloud(device, in: placeId)` event.
                    self?.completePairing()
                case .pairingCancelled:
                    // Pairing was cancelled prior commisioning the Device in nami cloud.
                    self?.completePairing()
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
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
