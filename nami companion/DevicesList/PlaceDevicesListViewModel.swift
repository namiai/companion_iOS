
import Foundation
import Combine
import NamiPairingFramework
import SwiftUI

final class PlaceDevicesListViewModel: ObservableObject {
    enum EmptyPlaceError: Error {
        case noZoneOrRoom
    }
    
    struct State {
        var pairingInRoomId: String
        var devices: [Device] = []
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(state: State, api: WebAPIProtocol, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.api = api
        self.nextRoute = nextRoute
        self.updateDevices()
    }
    
#if DEBUG
    
    init() {
        state = State(
            pairingInRoomId: UUID().uuidString,
            devices: [
                Device(
                    id: 3,
                    uid: DeviceUniversalID(3),
                    urn: "",
                    roomId: 1,
                    name: "The device",
                    createdAt: Date(),
                    updatedAt: Date(),
                    model: DeviceModel(
                        codeName: "the_device",
                        productLabel: "Product",
                        productId: 3
                    )
                ),
            ]
        )
        api = WebAPI(base: URL(string: "http://dumb.org")!, signUpBase: URL(string: "http://dumb.org")!, session: URLSession.shared, tokenStore: TokenSecureStorage(server: ""))
        nextRoute = { _ in }
    }
    
#endif
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private let api: WebAPIProtocol
    private var disposable = Set<AnyCancellable>()
    
    func updateDevices() {
        api.listDevices(query: .parameters())
            .map(\.devices)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(_) = completion {
                    DispatchQueue.main.async {
                        self.state.offerRetry = true
                    }
                    return
                }
            } receiveValue: { [weak self] devices in
                DispatchQueue.main.async {
                    self?.state.devices = devices
                    self?.state.offerRetry = false
                }
            }
            .store(in: &disposable)
    }
    
    func presentPairing() {
        nextRoute(.pairing(state.pairingInRoomId))
    }
}
