// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import StandardPairingUI
import SwiftUI

final class PairingManager {
    public enum GuideAction {
        case startPairing(roomId: RoomID)
        case cancel
        case error(Error)
    }
    
    public var errorPublisher = PassthroughSubject<Error, Never>()
    private var config: NamiSdkConfig
    
    // MARK: Lifecycle
    
    init(sessionCode: String, clientId: String, templatesBaseUrl: String, countryCode: String, language: String, appearance: NamiAppearance, measurementSystem: NamiMeasurementSystem, onError: @escaping (Error) -> Void) throws {
        self.sessionCode = sessionCode
        self.clientId = clientId
        self.templatesBaseUrl = templatesBaseUrl
        self.countryCode = countryCode
        self.language = language
        self.appearance = appearance
        self.measurementSystem = measurementSystem
        self.onErrorCallback = onError
        self.config = NamiSdkConfig(
            baseURL: URL(string:templatesBaseUrl)!,
            countryCode: countryCode,
            measurementSystem: measurementSystem,
            clientId: clientId,
            language: language,
            appearance: appearance
        )
        self.pairing = try NamiPairing<ViewsContainer>(
            sessionCode: sessionCode,
            wifiStorage: InMemoryWiFiStorage(),
            threadDatasetStore: InMemoryThreadDatasetStorage.self
        )
        
        try setupSubscription()
    }
    
    // MARK: Internal
    
    func startPairing(
        roomId: String,
        bssidPin: [UInt8]?,
        onPairingComplete: (([UInt8]?, DeviceID?, Bool?) -> Void)? = nil
    ) -> some View {
        self.onPairingComplete = onPairingComplete
        do {
            return try AnyView(
                pairing.startPairing(
                    roomId: roomId,
                    pairingSteps: ViewsContainer(),
                    // Plaese notice the BSSID pin is passed here to limit the WIFi networks search.
                    // Here it is in form of `[UInt8]` but also could be `Data` or ":"-separated MAC-formatted `String`.
                    pairingParameters: bssidPin == nil ? NamiPairing.PairingParameters() : NamiPairing.PairingParameters(bssid: bssidPin!)
                )
            )
        } catch {
            return AnyView(
                VStack{
                    Text("The Room ID provided could not be found in the Place topology.")
                    Button("Back to Place") {
                        self.completePairing()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                })
        }
    }
    
    func startPositioning(deviceName: String, deviceUid: String, onPositioningComplete: (() -> Void)? = nil) -> some View {
        self.onPositioningComplete = onPositioningComplete
        do {
            return try AnyView(
                pairing.startPositioning(
                    deviceName: deviceName, 
                    deviceUid: deviceUid, 
                    pairingSteps: ViewsContainer(), 
                    onPositioningEnded: { result in 
                        self.completePositioning()
                    })
            )
        } catch {
            return AnyView(
                VStack{
                    Text("The Device name or UID provided could not be found in.")
                    Button("Back to Place") {
                        self.completePositioning()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                })
        }
    }
    
    @MainActor func presentSingleDeviceSetup(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            pairing.presentEntryPoint(entrypoint: RemoteTemplateEntrypoint.setupDeviceGuide, config: self.config, pairingSteps: ViewsContainer())
        )
    }
    
    @MainActor func presentSetupGuide(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            pairing.presentEntryPoint(entrypoint: RemoteTemplateEntrypoint.setupKitGuide, config: self.config, pairingSteps: ViewsContainer())
        )
    }
    
    @MainActor func presentSettings(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            pairing.presentEntryPoint(entrypoint: RemoteTemplateEntrypoint.settings, config: self.config, pairingSteps: ViewsContainer())
        )
    }
    
    enum TemporarilyEndpoint: String, RemoteTemplateEntrypointProtocol {
        case namePin = "/name-pin.json"
    }
    
    @MainActor func presentPinCreation(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            pairing.presentEntryPoint(entrypoint: TemporarilyEndpoint.namePin, config: self.config, pairingSteps: ViewsContainer())
        )
    }
    
    // MARK: Private
    
    private var subscriptions = Set<AnyCancellable>()
    private var device: Device?
    private var onPairingComplete: (([UInt8]?, DeviceID?, Bool?) -> Void)?
    private var onPositioningComplete: (() -> Void)?
    private var onGuideComplete: ((GuideAction) -> Void)?
    private let sessionCode: String
    private let clientId: String
    private let templatesBaseUrl: String
    private let countryCode: String
    private let language: String
    private let appearance: NamiAppearance
    private let measurementSystem: NamiMeasurementSystem
    private let onErrorCallback: (Error) -> Void
    private let pairing: NamiPairing<ViewsContainer>
    
    var api: any PairingWebAPIProtocol {
        pairing.api
    }

    var threadDatasetProvider: any PairingThreadOperationalDatasetProviderProtocol {
        pairing.threadDatasetProvider
    }
    
    var placeId: PlaceID {
        pairing.placeId
    } 
    
    private func setupSubscription() throws {
        pairing.devicePairingState
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.warning("[PairingManager] Device state publisher failed with error: \(error.localizedDescription)")
                }
                guard let self else { return }
                self.completePairing()
            } receiveValue: { [weak self] deviceState in
                Log.info("[PairingManager] got device state \(deviceState)")
                switch deviceState {
                case .deviceCommisionedAtCloud(let device, in: _):
                    // Here the associated values might be obtained for case:
                    // `.deviceCommisionedAtCloud(device, in: placeId)`.
                    // For this demo we don't store device but would later obtain it from API.
                    // The pairing is not over yet.
                    self?.device = device as? Device
                    break
                case .deviceOperable(let deviceId, _, ssid: _, bssid: let bssid, positionAdjustmentNeeded: let repositionNeeded):
                    // Device is fully commisioned.
                    // Values with device ID, network SSID and BSSID pin could be obtained `.deviceOperable(deviceId, ssid: ssid, bssid: bssid)`.
                    if repositionNeeded == true {
                        self?.completePairing(bssid: bssid, deviceId: deviceId, repositionNeeded: repositionNeeded)
                        break
                    }
                    self?.completePairing(bssid: bssid)
                case .deviceDecommissioned:
                    // Pairing was cancelled/errored unrecoverably after commisioning the Device in nami cloud.
                    // Value with device ID could be obtained `.deviceDecommissioned(deviceId)`
                    // to revert the actions the SDK consumer might took
                    // after getting the device on `.deviceCommisionedAtCloud(device, in: placeId)` event.
                    self?.completePairing()
                case .pairingCancelled:
                    // Pairing was cancelled prior commisioning the Device in nami cloud.
                    self?.completePairing()
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        pairing.setupGuideState
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.warning("[PairingManager] Guide state publisher failed with error: \(error.localizedDescription)")
                    
                    self?.onGuideComplete?(.error(error))
                }
            } receiveValue: { [weak self] event in
                switch event {
                case .gotUrl(_):
                    break
                case .variableUpdated(_, _):
                    break
                case .viewDismissed:
                    self?.onGuideComplete?(.cancel)
                case let .pairingRequested(_, _, roomId, _, _, _):
//                    self?.onGuideComplete?(.startPairing(roomId: roomId))
                    break
                case .warning(_):
                    break
                }
                
            }
            .store(in: &subscriptions)
    }
    
    private func completePairing(bssid: [UInt8]? = nil, deviceId: DeviceID? = nil, repositionNeeded: Bool? = nil) {
        onPairingComplete?(bssid, deviceId, repositionNeeded)
        onPairingComplete = nil
    }
    
    private func completePositioning() {
        onPositioningComplete?()
        onPositioningComplete = nil
    }
}
