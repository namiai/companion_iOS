// Copyright (c) nami.ai

import Foundation
import Combine
import NamiPairingFramework
import SwiftUI

struct CompanionError: Error, Equatable {
    let error: Error
    let detailedMessage: String
    
    static func ==(lhs: CompanionError, rhs: CompanionError) -> Bool {
        return lhs.detailedMessage == rhs.detailedMessage
    }
}

final class SessionCodeViewModel: ObservableObject {    
    init(setupPairingManager: @escaping (PairingManager) -> Void, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.setupPairingManager = setupPairingManager
        self.nextRoute = nextRoute
    }
    
    struct State {
        var sessionCode: String = ""
        var clientId: String = "nami_dev"
        var baseUrl: String = "https://mobile-screens.nami.surf/divkit/v0.13.0/precompiled_layouts"
        var countryCode: String = "us"
        var language: String = "en-US"
        var appearance: NamiSdkConfig.Appearance = .system
        var measurementSystem: NamiSdkConfig.MeasurementSystem = .metric
        var topologyRoomsSupported: Bool = false
        var buttonTapped = false
        var error: CompanionError? = nil 
        
        var disableButton: Bool {
            buttonTapped ||
            sessionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    @Published var state: State = State()
    private var pairingManager: PairingManager?
    private var disposable = Set<AnyCancellable>()
    private var setupPairingManager: (PairingManager) -> Void
    private var nextRoute: (RootRouter.Routes) -> Void
    
    func clearError() {
        self.state.error = nil
    }
    func confirmTapped(onError: @escaping () -> ()) {
        self.state.buttonTapped = true
        DispatchQueue(label: "PairingInitializingQueue", qos: .default).async { [unowned self] in
            do {
                let pairingManager = try PairingManager(
                    sessionCode: state.sessionCode, 
                    clientId: state.clientId,
                    templatesBaseUrl: state.baseUrl,
                    countryCode: state.countryCode,
                    language: state.language,
                    appearance: state.appearance,
                    measurementSystem: state.measurementSystem,
                    topologyRoomsSupported: state.topologyRoomsSupported,
                    onError: { error in
                        DispatchQueue.main.async {
                            self.state.error = CompanionError(error: error, detailedMessage: error.localizedDescription)
                        }
                    }
                )
                setupPairingManager(pairingManager)
            } catch {
                DispatchQueue.main.async {
                    if let e = error as? SDKError {
                        switch e {
                        case let .sessionActivateMalformedResponse(data):
                            let message = "[Pairing init] SDK Error: \(e.localizedDescription), containing unparsed data: \(String(data: data, encoding: .utf8) ?? "failed to encode into utf8 string")"
                            print(message)
                            self.state.error = CompanionError(error: e, detailedMessage: e.localizedDescription)
                        default:
                            print("[Pairing init] SDK Error: \(e.localizedDescription)")
                            self.state.error = CompanionError(error: e, detailedMessage: e.localizedDescription)
                        }
                    } else {
                        print("[Pairing init] Error: \(error.localizedDescription)")
                        self.state.error = CompanionError(error: error, detailedMessage: error.localizedDescription)
                    }
                    self.state.buttonTapped = false
                    onError()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.nextRoute(.placeDevices)
                self.state.buttonTapped = false
            }
        }
    }
    
}
