// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import SwiftUI

final class PairingManager {
    public enum GuideAction {
        case cancel
        case error(Error)
    }
    
    public var errorPublisher = PassthroughSubject<Error, Never>()
    private var config: NamiSdkConfig
    
    // MARK: Lifecycle
    
    init(sessionCode: String, clientId: String, templatesBaseUrl: String, countryCode: String, language: String, appearance: NamiSdkConfig.Appearance, measurementSystem: NamiSdkConfig.MeasurementSystem, onError: @escaping (Error) -> Void) throws {
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
        self.pairing = try NamiPairing(
            sessionCode: sessionCode
        )
    }
    
    // MARK: Internal
    
    func startPositioning(deviceName: String, deviceUid: String, onPositioningComplete: (() -> Void)? = nil) -> some View {
        EmptyView()
    }
    
    @MainActor func presentSingleDeviceSetup(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.setupDeviceGuide, config: self.config)
        )
    }
    
    @MainActor func presentSetupGuide(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.setupKitGuide, config: self.config)
        )
    }
    
    @MainActor func presentSettings(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.settings, config: self.config)
        )
    }
    
    enum TemporarilyEndpoint: String, SDKRemoteTemplateEntrypointProtocol {
        case namePin = "/name-pin.json"
    }
    
    @MainActor func presentPinCreation(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
        try! pairing.presentEntryPoint(TemporarilyEndpoint.namePin, config: self.config)
        )
    }
    
    // MARK: Private
    
    private var subscriptions = Set<AnyCancellable>()
    private var onPairingComplete: (([UInt8]?, NamiDeviceID?, Bool?) -> Void)?
    private var onPositioningComplete: (() -> Void)?
    private var onGuideComplete: ((GuideAction) -> Void)?
    private let sessionCode: String
    private let clientId: String
    private let templatesBaseUrl: String
    private let countryCode: String
    private let language: String
    private let appearance: NamiSdkConfig.Appearance
    private let measurementSystem: NamiSdkConfig.MeasurementSystem
    private let onErrorCallback: (Error) -> Void
    private let pairing: NamiPairing
    
    var placeId: NamiPlaceID {
        pairing.sessionPlaceId!
    }
    
    private func completePairing(bssid: [UInt8]? = nil, deviceId: NamiDeviceID? = nil, repositionNeeded: Bool? = nil) {
        onPairingComplete?(bssid, deviceId, repositionNeeded)
        onPairingComplete = nil
    }
    
    private func completePositioning() {
        onPositioningComplete?()
        onPositioningComplete = nil
    }
}
