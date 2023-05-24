// Copyright (c) nami.ai

import Combine
import Foundation
import NamiStandardPairingFramework
import SwiftUI

final class PairingManager {
    // MARK: Lifecycle
    
    init(session: SessionCodeActivateResult) {
        pairing = StandardPairing(session: session)
        setupSubscription()
    }
    
    // MARK: Internal
    
    func startPairing(
        zoneUuid: String,
        roomUuid: String,
        onPairingComplete: (() -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        do {
            return try AnyView(pairing.startPairing(zoneUuid: zoneUuid, roomUuid: roomUuid))
        } catch {
            // Don't really care for a demo. Showing some error view or warning might be helpful.
            return AnyView(EmptyView())
        }
    }
    
    // MARK: Private
    
    private var pairing: StandardPairing
    private var subscriptions = Set<AnyCancellable>()
    private var onPairingComplete: (() -> Void)?
    
    var api: WebAPIProtocol {
        pairing.api
    }
    
    static func activateSession(code: String) -> Result<SessionCodeActivateResult, Error> {
        StandardPairing.activateSession(code: code)
    }
    
    private func setupSubscription() {
        pairing.sdk.devicePairingState
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
                    break
                default:
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
