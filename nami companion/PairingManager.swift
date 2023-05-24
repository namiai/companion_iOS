// Copyright (c) nami.ai

import Combine
import Foundation
import NamiStandardPairingFramework
import SwiftUI

final class PairingManager {
    // MARK: Lifecycle
    
    init(sessionCode: String) {
        pairing = try! StandardPairing(sessionCode: sessionCode)
        setupSubscription()
    }
    
    // MARK: Internal
    
    func startPairing(
        roomId: String,
        onPairingComplete: (() -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        do {
            return try AnyView(pairing.startPairing(roomId: roomId))
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
    
    private var pairing: StandardPairing
    private var subscriptions = Set<AnyCancellable>()
    private var onPairingComplete: (() -> Void)?
    
    var api: WebAPIProtocol {
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
