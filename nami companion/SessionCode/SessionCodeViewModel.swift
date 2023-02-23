
import Foundation
import Combine
import WebAPI
import TokenStore
import CommonTypes
import SwiftUI
import Log

final class SessionCodeViewModel: ObservableObject {
    
    init(services: ApplicationServices, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.services = services
        self.nextRoute = nextRoute
    }
    
#if DEBUG
    
    init() {
        services = ApplicationServices()
        nextRoute = { _ in }
    }
    
#endif
    
    struct State {
        var sessionCode: String = ""
        var apiKey: String = ""
        fileprivate var buttonTapped = false
        fileprivate var place: Place?
        fileprivate var zoneId: PlaceZoneID?
        fileprivate var roomId: RoomID?
        
        var disableButton: Bool {
            buttonTapped ||
            sessionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    @Published var state: State = State()
    private var services: ApplicationServices
    private var disposable = Set<AnyCancellable>()
    private var nextRoute: (RootRouter.Routes) -> Void
    
    func confirmTapped() {
        state.buttonTapped = true
        let api = self.services.setupAPI(apiKey: state.apiKey)
        api.installerSessionActivate(with: state.sessionCode)
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
            } receiveValue: { [weak self] result in
                Log.info("Session activate result", result)
                guard let tokenStore = self?.services.tokenStore else { return }
                tokenStore.store(token: result.authentication.accessToken, at: .access)
                tokenStore.store(token: result.authentication.refreshToken, at: .refresh)
                DispatchQueue.main.async {
                    self?.nextRoute(
                        .placeDevices(
                            result.place,
                            result.sessionParameters.flatModeDefaults["zone_id"]!,
                            result.sessionParameters.flatModeDefaults["room_id"]!)
                    )
                }
            }
            .store(in: &disposable)
    }
    
}
