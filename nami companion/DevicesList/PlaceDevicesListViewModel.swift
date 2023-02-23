//
//  PlaceDevicesListViewModel.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import Foundation
import Combine
import WebAPI
import CommonTypes
import SwiftUI
import WiFiStorage

#if DEBUG

import TokenStore

#endif

final class PlaceDevicesListViewModel: ObservableObject {
    
    struct State {
        var place: Place
        var zoneId: PlaceZoneID
        var roomId: RoomID
        var devices: [Device] = []
        var offerRetry = false
        var presentingPairing = false
    }
    
    init(state: State, api: WebAPIProtocol, nextRoute: @escaping (RootRouter.Routes) -> Void) {
        self.state = state
        self.api = api
        self.nextRoute = nextRoute
        self.pairingManager = PairingManager(api: api, wifiStorage: WiFiStorage(), onGetDevice: { [weak self] device in
            self?.addDevice(device)
        }, onDeleteDevice: { [weak self] deviceId in
            self?.removeDevice(deviceId)
        })
        self.updateDevices()
    }
    
#if DEBUG
    
    init() {
        state = State(
            place: Place(
                id: 1,
                urn: "",
                name: "The Demo Place",
                createdAt: Date(),
                updatedAt: Date(),
                themeId: 1,
                iconId: 1,
                zones: [],
                limits: .init(membership: 100)
            ),
            zoneId: 1,
            roomId: 1,
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
        self.pairingManager = PairingManager(api: api, wifiStorage: WiFiStorage(), onGetDevice: { [weak self] device in
            self?.addDevice(device)
        }, onDeleteDevice: { [weak self] deviceId in
            self?.removeDevice(deviceId)
        })
    }
    
#endif
    
    @Published var state: State
    let nextRoute: (RootRouter.Routes) -> Void
    private let api: WebAPIProtocol
    private var disposable = Set<AnyCancellable>()
    private var pairingManager: PairingManager!
    
    func updateDevices() {
        api.listDevices(query: .parameters(placeIds: [state.place.id]))
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
    
    @ViewBuilder
    func buildPairingView() -> some View {
        pairingManager.startPairing(placeId: state.place.id, zoneId: state.zoneId, roomId: state.roomId) { [weak self] in
            DispatchQueue.main.async {
                self?.state.presentingPairing = false
            }
        }
    }
    
    private func addDevice(_ device: Device) {
        DispatchQueue.main.async {
            self.state.devices.append(device)
        }
    }
    
    private func removeDevice(_ deviceId: DeviceID) {
        DispatchQueue.main.async {
            self.state.devices.removeAll { device in
                device.id == deviceId
            }
        }
    }
}
