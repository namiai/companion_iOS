//
//  ErrorPresentationViewModel.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import WebAPI

final class ErrorPresentationViewModel: ObservableObject {
    struct State {
        var error: Error
        
        var errorMessage: String {
            if let e = error as? NetworkError {
                return e.customErrorDescription ?? e.localizedDescription
            }
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
