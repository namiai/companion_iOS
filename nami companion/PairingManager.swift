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
            pairing = try NamiPairing<ViewsContainer>(sessionCode: sessionCode)
            setupSubscription()
        } catch {
            if let e = error as? NetworkError {
                Log.warning("[Pairing init] Network Error: \(e.localizedDescription)")
            }
            if let e = error as? NamiPairing<ViewsContainer>.SDKError {
                switch e {
                case let .sessionActivateMalformedResponse(data):
                    Log.warning("[Pairing init] SDK Error: \(e.localizedDescription), containing unparsed data: \(String(data: data, encoding: .utf8))")
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
        onPairingComplete: (() -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        do {
            return try AnyView(pairing.startPairing(roomId: roomId, pairingSteps: ViewsContainer()))
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
    
    // MARK: Private
    
    private var pairing: NamiPairing<ViewsContainer>
    private var subscriptions = Set<AnyCancellable>()
    private var onPairingComplete: (() -> Void)?
    
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
                case .deviceCommisionedAtCloud:
                    // Here the associated values might be obtained for case:
                    // `.deviceCommisionedAtCloud(device, in: placeId)`.
                    // For this demo we don't store device but would later obtain it from API.
                    // The pairing is not over yet.
                    break
                case .deviceOperable:
                    // Device is fully commisioned.
                    // Value with device ID could be obtained `.deviceOperable(deviceId)`.
                    self?.completePairing()
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
    
    private func completePairing() {
        onPairingComplete?()
        onPairingComplete = nil
    }
}
