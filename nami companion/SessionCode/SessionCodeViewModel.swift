
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
        fileprivate var buttonTapped = false
        fileprivate var place: Place?
        fileprivate var zoneId: PlaceZoneID?
        fileprivate var roomId: RoomID?
        
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
        state.buttonTapped = true
        StandardPairing.activateSession(code: state.sessionCode)
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                Log.info("Session activate completion", completion)
                guard let self else { return }
                DispatchQueue.main.async {
                    self.state.buttonTapped = false
                }
                if case let .failure(error) = completion {
                    self.nextRoute(.errorView(error))
                }
            } receiveValue: { [weak self] (result: SessionCodeActivateResult) in
                Log.info("Session activate result", result)
                let pairingManager = PairingManager(session: result)
                self?.setupPairingManager(pairingManager)
                DispatchQueue.main.async {
                    self?.nextRoute(.placeDevices(result.place))
                }
            }
            .store(in: &disposable)
    }
    
}
