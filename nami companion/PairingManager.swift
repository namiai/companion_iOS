// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import SwiftUI
import CommonTypes
import ISO8601MsecDecoder
import WebAPI
import TokenStore

final class PairingManager {
    enum GuideAction {
        case cancel
        case error(Error)
    }
    
    var errorPublisher = PassthroughSubject<Error, Never>()
    private var config: NamiSdkConfig
    
    // MARK: Lifecycle
    
    init(sessionCode: String, tokenStore: TokenSecureStorage, clientId: String, templatesBaseUrl: String, countryCode: String, language: String, appearance: NamiSdkConfig.Appearance, measurementSystem: NamiSdkConfig.MeasurementSystem, onError: @escaping (Error) -> Void) throws {
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
        self.session = try! Self.activateSession(code: sessionCode).get()
        let urlSession = URLSession.shared
        tokenStore.store(token: session?.authentication.accessToken, at: .access)
        tokenStore.store(token: session?.authentication.refreshToken, at: .refresh)
        
        self.pairing = NamiPairing(baseURL: PairingHelper.baseUrl, session: urlSession, tokenStore: tokenStore)
        self.pairing.sdkEventsPublisher.sink { [weak self] completion in
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
    
    enum TemporarilyEndpoint: String, SDKRemoteTemplateEntrypointProtocol {
        case namePin = "/name-pin.json"
    }
    
    @MainActor func presentPinCreation(onGuideComplete: ((GuideAction) -> Void)?) -> some View {
        self.onGuideComplete = onGuideComplete
        return AnyView(
        try! pairing.presentEntryPoint(TemporarilyEndpoint.namePin, placeId: NamiPlaceID(session!.place.id), config: self.config)
        )
    }
    
    // MARK: Private
    
    private var subscriptions = Set<AnyCancellable>()
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
    private var cancellables = Set<AnyCancellable>()
    
    var placeId: NamiPlaceID {
        NamiPlaceID(session!.place.id)
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
        let request = URLRequest(
            method: "POST",
            base: PairingHelper.baseUrl,
            path: "/session-codes/\(code)/activate",
            headers: ["Content-Type": "application/json"]
        )

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
        guard let activationResult = try? PairingHelper.decoder.decode(
            SessionCodeActivateResult.self,
            from: responseData
        ) else {
            return .failure(SDKError.sessionActivateMalformedResponse(responseData))
        }

        return .success(activationResult)
    }
}

// MARK: - SessionCodeActivateResult

struct SessionCodeActivateResult: Decodable {
    // MARK: Lifecycle

    init(sessionParameters: SessionParameters, authentication: CompanionModeAuthentication, place: Place) {
        self.sessionParameters = sessionParameters
        self.authentication = authentication
        self.place = place
    }

    // MARK: Public

    var sessionParameters: SessionParameters
    var authentication: CompanionModeAuthentication
    var place: Place

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case sessionParameters = "session_parameters"
        case authentication
        case place
    }
}

// MARK: - SessionParameters

// Encodable and Equatable are added to allow SessionParameters in UserSettings.
struct SessionParameters: Codable, Equatable {
    // MARK: Lifecycle

    init(permissions: [String], mode: String, flatModeDefaults: [String: Int64], partnerName: String, partnerLogoUrl: URL, redirectUri: URL) {
        self.permissions = permissions
        self.mode = mode
        self.flatModeDefaults = flatModeDefaults
        self.partnerName = partnerName
        self.partnerLogoUrl = partnerLogoUrl
        self.redirectUri = redirectUri
    }

    // MARK: Public

    var permissions: [SessionPermission]
    var mode: String
    var flatModeDefaults: [String: Int64] // TODO: Introduce expected keys enum to filter the array.
    var partnerName: String
    var partnerLogoUrl: URL?
    var redirectUri: URL

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case permissions
        case mode
        case flatModeDefaults = "flat_mode"
        case partnerName = "partner_name"
        case partnerLogoUrl = "partner_logo_url"
        case redirectUri = "redirect_uri"
    }
}

// MARK: - CompanionModeUser

struct CompanionModeUser: Decodable {
    // MARK: Lifecycle

    init(id: UserID, username: String) {
        self.id = id
        self.username = username
    }

    // MARK: Public

    var id: UserID
    var username: String
}

struct PairingHelper {
    static let decoder = JSONDecoder.ISO8601Msec()
    static let baseUrl = URL(string: "https://mimizan.nami.surf")!
}

struct AccessToken: Equatable, Codable {
    // MARK: Lifecycle

    init(accessToken: TokenString, expiresAt: Date) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
    }

    // MARK: Public

    var accessToken: TokenString
    var expiresAt: Date

    func isValid() -> Bool {
        expiresAt > Date()
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresAt = "expires_at"
    }
}

extension URLSession: @retroactive NamiPairingNetworkSession {
    public func publisher(for request: URLRequest, accessToken: String, tokenExpiresAt: Date, retries: Int, backoffBase: Double) -> AnyPublisher<Data, any Error> {
        self.publisher(for: request, token: .init(accessToken: accessToken, expiresAt: tokenExpiresAt), retries: retries, backoffBase: backoffBase, jitter: .decorrelated)
    }
    
    public func publisher(for request: URLRequest, accessToken: String, tokenExpiresAt: Date) -> AnyPublisher<Data, any Error> {
        self.publisher(for: request, token: .init(accessToken: accessToken, expiresAt: tokenExpiresAt)).eraseToAnyPublisher()
    }
}
extension TokenSecureStorage: @retroactive NamiPairingTokenStore {
    public func store<TokenType>(_ token: TokenType, at key: String) where TokenType : Decodable, TokenType : Encodable {
        if let storeKey = Tokens(rawValue: key) {
            self.store(token: token, at: storeKey)
        }
    }
    
    public func retrieve<TokenType>(_ type: TokenType.Type, from key: String) -> TokenType? where TokenType : Decodable, TokenType : Encodable {
        if let storeKey = Tokens(rawValue: key) {
            switch self.retrieve(a: type, from: storeKey) {
            case let .success(t):
                return t
            case .failure(_):
                return nil
            }
        }
        return nil
    }
    
    public func delete(at key: String) {
        if let storeKey = Tokens(rawValue: key) {
            self.delete(at: storeKey)
        }
    }
}
