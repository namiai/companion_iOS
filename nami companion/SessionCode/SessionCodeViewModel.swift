// Copyright (c) nami.ai

import Foundation
import Combine
import NamiPairingFramework
import SwiftUI
import TokenStore
import WebAPI

struct CompanionError: Error, Equatable {
    let error: Error
    let detailedMessage: String
    
    static func ==(lhs: CompanionError, rhs: CompanionError) -> Bool {
        return lhs.detailedMessage == rhs.detailedMessage
    }
}

final class SessionCodeViewModel: ObservableObject {    
    init(setupPairingManager: @escaping (PairingManager, WebAPI) -> Void, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.setupPairingManager = setupPairingManager
        self.nextRoute = nextRoute
    }
    
    struct State {
        var sessionCode: String = ""
        var clientId: String = "nami_dev"
        var baseUrl: String = "https://mobile-screens.nami.surf/divkit/v0.6.0/precompiled_layouts"
        var countryCode: String = "us"
        var language: String = "en-US"
        var appearance: NamiSdkConfig.Appearance = .system
        var measurementSystem: NamiSdkConfig.MeasurementSystem = .metric
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
    private var setupPairingManager: (PairingManager, WebAPI) -> Void
    private var nextRoute: (RootRouter.Routes) -> Void
    
    func clearError() {
        self.state.error = nil
    }
    func confirmTapped(onError: @escaping () -> ()) {
        self.state.buttonTapped = true
        DispatchQueue(label: "PairingInitializingQueue", qos: .default).async { [unowned self] in
            do {
                let tokenStore = TokenSecureStorage(server: "nami.companionapp.apitoken.securestorage.dev")
                let pairingManager = try PairingManager(
                    sessionCode: state.sessionCode,
                    tokenStore: tokenStore,
                    clientId: state.clientId,
                    templatesBaseUrl: state.baseUrl,
                    countryCode: state.countryCode,
                    language: state.language,
                    appearance: state.appearance,
                    measurementSystem: state.measurementSystem,
                    onError: { error in
                        fatalError(error.localizedDescription)
                    }
                )
                let api = WebAPI(
                    base: PairingHelper.baseUrl,
                    signUpBase: PairingHelper.baseUrl,
                    session: URLSession.shared,
                    tokenStore: tokenStore
                )
                setupPairingManager(pairingManager, api)
            } catch {
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.state.buttonTapped = false
                    onError()
                }
                return
            }
            
            DispatchQueue.main.async {
                // BSSID pin yet unknown here.
                // It is okay for the new place and for a place with only nami devices
                // because the pin would be set for first paired device or
                // in case if there are any nami devices paired already in the sensing zone and no explicit pin is passed to pairing
                // the pin would be obtained from backend.
                // If no nami devices were paired in the sensing zone a BSSID pin should be passed to the pairing.
                // To request the pre-existent BSSID pin from the user as it might be requested from the application useing the framework
                // is out of scope for this demo app.
                // Pin would be obtained for the subsequent pairings on pairing success (see `PairingManager.startPairing(...)`) and shown on top of devices list.
                self.nextRoute(.placeDevices)
                self.state.buttonTapped = false
            }
        }
    }
    
}
