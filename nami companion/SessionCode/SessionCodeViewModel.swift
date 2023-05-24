
import Foundation
import Combine
import NamiStandardPairingFramework
import SwiftUI

final class SessionCodeViewModel: ObservableObject {
    
    init( setupPairingManager: @escaping (PairingManager) -> Void, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.setupPairingManager = setupPairingManager
        self.nextRoute = nextRoute
    }
    
#if DEBUG
    
    init() {
        setupPairingManager = { _ in }
        nextRoute = { _ in }
    }
    
#endif
    
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
            let pairingManager = PairingManager(sessionCode: state.sessionCode)
            setupPairingManager(pairingManager)
        }
        DispatchQueue.main.async {
            self.nextRoute(.placeDevices(self.state.roomId))
            self.state.buttonTapped = false
        }
    }
    
}
