// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import SwiftUI

final class PairingManager {
    enum GuideAction {
        case cancel
        case error(Error)
    }
    
    var errorPublisher = PassthroughSubject<Error, Never>()
    private var config: NamiSdkConfig
    
    // MARK: Lifecycle
    
    init(sessionCode: String, clientId: String, templatesBaseUrl: String, countryCode: String, language: String, appearance: NamiSdkConfig.Appearance, measurementSystem: NamiSdkConfig.MeasurementSystem, topologyRoomsSupported: Bool, onError: @escaping (Error) -> Void) throws {
        self.sessionCode = sessionCode
        self.clientId = clientId
        self.templatesBaseUrl = templatesBaseUrl
        self.countryCode = countryCode
        self.language = language
        self.appearance = appearance
        self.measurementSystem = measurementSystem
        self.onErrorCallback = onError
        self.config = NamiSdkConfig(
            baseURL: URL(string: templatesBaseUrl)!,
            countryCode: countryCode,
            measurementSystem: measurementSystem,
            clientId: clientId,
            language: language,
            appearance: appearance,
            topologyRoomsSupported: topologyRoomsSupported
        )

        self.session = try Self.activateSession(code: sessionCode).get()

        let tokenStore = CompanionTokenStore()
        tokenStore.store(session!.authentication.accessToken, at: "access_token")
        tokenStore.store(session!.authentication.refreshToken, at: "refresh_token")

        self.pairing = NamiPairing(
            baseURL: Self.baseUrl,
            tokenStore: tokenStore,
            threadSecureStorage: KeychainThreadDatasetStorage.self
        )
        
        self.pairing.sdkEventsPublisher
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.onGuideComplete?(.error(error))
                }
            } receiveValue: { [weak self] event in
                if case .dismissView = event {
                    self?.onGuideComplete?(.cancel)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Internal
    
    func startPositioning(deviceName: String, deviceUid: String, onPositioningComplete: (() -> Void)? = nil) -> some View {
        EmptyView()
    }
    
    @MainActor func presentSingleDeviceSetup(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.setupDeviceGuide, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }
    
    @MainActor func presentSetupGuide(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.setupKitGuide, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }
    
    @MainActor func presentSettings(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.settings, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }

    @MainActor func presentSettingsForEntity(urn: String, onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(
                RemoteTemplateEntrypoint.settings.with(entityID: urn),
                placeId: NamiPlaceID(session!.place.id),
                config: self.config
            )
        )
    }

    @MainActor func presentUpdateWiFiCredentials(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.updateWifiCredentials, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }

    @MainActor func presentEntryExitDelaySettings(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.settingsEntryExitDelays, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }
    
    @MainActor func presentSystemCheckup(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(RemoteTemplateEntrypoint.testSystem,
                                           placeId: NamiPlaceID(session!.place.id),
                                           config: self.config)
        )
    }
    
    enum TemporarilyEndpoint: String, SDKRemoteTemplateEntrypointProtocol {
        case testSystems = "/test-system/kit/alarm_com_falcon.json"
        case namePin = "/settings-pins.json"
    }
    
    @MainActor func presentTestSystems(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(TemporarilyEndpoint.testSystems,
                                           placeId: NamiPlaceID(session!.place.id),
                                           config: self.config)
        )
    }
    
    @MainActor func presentPinCreation(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
            try! pairing.presentEntryPoint(TemporarilyEndpoint.namePin,
                                           placeId: NamiPlaceID(session!.place.id),
                                           config: self.config)
        )
    }
    
    // MARK: Private
    
    private var subscriptions = Set<AnyCancellable>()
    private var cancellables = Set<AnyCancellable>()
    private var onPairingComplete: (([UInt8]?, NamiDeviceID?, Bool?) -> Void)?
    private var onPositioningComplete: (() -> Void)?
    private var onGuideComplete: ((GuideAction) -> Void)?
    private let sessionCode: String
    private var session: SessionCodeActivateResult?
    private let clientId: String
    private let templatesBaseUrl: String
    private let countryCode: String
    private let language: String
    private let appearance: NamiSdkConfig.Appearance
    private let measurementSystem: NamiSdkConfig.MeasurementSystem
    private let onErrorCallback: (Error) -> Void
    private let pairing: NamiPairing
    
    static let baseUrl = URL(string: "https://mimizan.nami.surf")!
    
    var placeId: NamiPlaceID {
        NamiPlaceID(session!.place.id)
    }
    
    var accessToken: String? {
        session?.authentication.accessToken.accessToken
    }
    
    private func completePairing(bssid: [UInt8]? = nil, deviceId: NamiDeviceID? = nil, repositionNeeded: Bool? = nil) {
        onPairingComplete?(bssid, deviceId, repositionNeeded)
        onPairingComplete = nil
    }
    
    private func completePositioning() {
        onPositioningComplete?()
        onPositioningComplete = nil
    }
    
    private static func activateSession(code: String) -> Result<SessionCodeActivateResult, Error> {
        var urlComponents = URLComponents(string: baseUrl.absoluteString + "/session-codes/\(code)/activate")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?
        var errorValue: Error?

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { semaphore.signal() }
            if let error {
                errorValue = error
                return
            }
            responseData = data
        }
        .resume()

        semaphore.wait()

        if let errorValue {
            return .failure(errorValue)
        }
        guard let responseData else {
            return .failure(SDKError.sessionActivateNoData)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        
        guard let activationResult = try? decoder.decode(
            SessionCodeActivateResult.self,
            from: responseData
        ) else {
            return .failure(SDKError.sessionActivateMalformedResponse(responseData))
        }

        return .success(activationResult)
    }
}

// MARK: - Token Store

final class CompanionTokenStore: NamiPairingTokenStore {
    private var storage: [String: Data] = [:]
    
    func store<TokenType>(_ token: TokenType, at key: String) where TokenType: Decodable, TokenType: Encodable {
        storage[key] = try? JSONEncoder().encode(token)
    }
    
    func retrieve<TokenType>(_ type: TokenType.Type, from key: String) -> TokenType? where TokenType: Decodable, TokenType: Encodable {
        guard let data = storage[key] else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func delete(at key: String) {
        storage.removeValue(forKey: key)
    }
}

// MARK: - In-Memory Storage Implementations

final class InMemoryWiFiStorage: SDKWiFiStorageProtocol, @unchecked Sendable {
    private var storage: [String: String] = [:]
    
    func save(password: String?, for networkSSID: String) {
        storage[networkSSID] = password
    }
    
    func password(for networkSSID: String) -> String? {
        storage[networkSSID]
    }
    
    func removeAll() {
        storage.removeAll()
    }
}

// MARK: - Session Code Activation Models

typealias TokenString = String
typealias UserID = Int64
typealias SessionPermission = String
typealias PlaceID = Int64

struct SessionCodeActivateResult: Decodable {
    var sessionParameters: SessionParameters
    var authentication: CompanionModeAuthentication
    var place: ActivatedPlace
    
    enum CodingKeys: String, CodingKey {
        case sessionParameters = "session_parameters"
        case authentication
        case place
    }
}

struct SessionParameters: Codable, Equatable {
    var permissions: [SessionPermission]
    var mode: String
    var flatModeDefaults: [String: Int64]
    var partnerName: String
    var partnerLogoUrl: URL?
    var redirectUri: URL
    
    enum CodingKeys: String, CodingKey {
        case permissions
        case mode
        case flatModeDefaults = "flat_mode"
        case partnerName = "partner_name"
        case partnerLogoUrl = "partner_logo_url"
        case redirectUri = "redirect_uri"
    }
}

struct CompanionModeAuthentication: Decodable {
    var user: CompanionModeUser
    var accessToken: AccessToken
    var refreshToken: TokenString
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct CompanionModeUser: Decodable {
    var id: UserID
    var username: String
}

struct AccessToken: Equatable, Codable {
    var accessToken: TokenString
    var expiresAt: Date
    
    func isValid() -> Bool {
        expiresAt > Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresAt = "expires_at"
    }
}

struct ActivatedPlace: Decodable {
    var id: PlaceID
    var name: String
}
