// Copyright (c) nami.ai

import Foundation
import Combine
import NamiPairingFramework
import SwiftUI

final class SessionCodeViewModel: ObservableObject {
    
    init( setupPairingManager: @escaping (PairingManager) -> Void, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.setupPairingManager = setupPairingManager
        self.nextRoute = nextRoute
    }
    
    struct State {
        var sessionCode: String = ""
        var roomId: String = ""
        var buttonTapped = false
        
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
    
    func confirmTapped() {
        DispatchQueue.main.async {
            self.state.buttonTapped = true
        }
        DispatchQueue(label: "PairingInitializingQueue", qos: .default).sync {
            let pairingManager = try! PairingManager(sessionCode: state.sessionCode)
            setupPairingManager(pairingManager)
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
            self.nextRoute(.placeDevices(self.state.roomId, nil))
            self.state.buttonTapped = false
        }
    }
    
}
