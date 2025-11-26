// Copyright (c) nami.ai

import Foundation
import NamiPairingFramework

final class ErrorPresentationViewModel: ObservableObject {
    struct State {
        var error: Error
        
        var errorMessage: String {
            return error.localizedDescription
        }
    }
    
    init(state: State, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.nextRoute = nextRoute
    }
    
#if DEBUG
    
    init() {
        self.state = State(error: NSError(domain: "Stupid error", code: 1))
        self.nextRoute = { _ in }
    }
    
#endif
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    
    func dismissError() {
        nextRoute(.codeInput)
    }
}
