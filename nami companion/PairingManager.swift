// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework
import Security
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
            threadDatasetProvider: InMemoryThreadDatasetProvider()
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

final class InMemoryThreadDatasetProvider: SDKThreadOperationalDatasetProviderProtocol, @unchecked Sendable {
    struct Dataset: SDKThreadOperationalDatasetProtocol {
        var data: Data

        func equalsNumericalPanID<ID>(_ panId: ID) -> Bool where ID: FixedWidthInteger {
            // Parse PAN ID TLV (type 0x01) from data to compare
            var offset = 0
            let bytes = [UInt8](data)
            while offset + 1 < bytes.count {
                let type = bytes[offset]
                let length = Int(bytes[offset + 1])
                if offset + 2 + length > bytes.count { break }
                if type == 0x01 && length == 2 {
                    let storedPanId = UInt16(bytes[offset + 2]) << 8 | UInt16(bytes[offset + 3])
                    return UInt16(panId) == storedPanId
                }
                offset += 2 + length
            }
            return false
        }
    }

    private var datasets: [Int64: Data] = [:]

    func newRandomDataset(networkName: String?) -> Dataset {
        Dataset(data: Self.generateRandomThreadDataset(networkName: networkName))
    }

    func getDataset(for placeId: NamiPlaceID) -> AnyPublisher<Dataset, any Error> {
        if let data = datasets[placeId.rawValue] {
            return Just(Dataset(data: data))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: NSError(domain: "ThreadDataset", code: -1, userInfo: [NSLocalizedDescriptionKey: "No dataset found"]))
            .eraseToAnyPublisher()
    }

    func removeDataset(for placeId: NamiPlaceID) {
        datasets.removeValue(forKey: placeId.rawValue)
    }

    func storeDataset(_ dataset: Data, for placeId: NamiPlaceID) {
        datasets[placeId.rawValue] = dataset
    }

    func storeDataset(_ dataset: Dataset, for placeId: NamiPlaceID) {
        datasets[placeId.rawValue] = dataset.data
    }

    // MARK: - Thread Operational Dataset TLV Generation

    /// Generates a valid Thread Operational Dataset in TLV format matching the Thread MeshCoP specification.
    private static func generateRandomThreadDataset(networkName: String?) -> Data {
        var tlvData = Data()

        // Channel (type 0x00): 1 byte channel page + 2 bytes channel number (big-endian)
        let channel = UInt16(Int.random(in: 11...26))
        tlvData.append(contentsOf: [0x00, 0x03, 0x00] + channel.bigEndianBytes)

        // PAN ID (type 0x01): 2 bytes (big-endian)
        let panId = UInt16.random(in: 0...UInt16.max)
        tlvData.append(contentsOf: [0x01, 0x02] + panId.bigEndianBytes)

        // Extended PAN ID (type 0x02): 8 bytes (big-endian)
        let extPanId = UInt64.random(in: 0...UInt64.max)
        tlvData.append(contentsOf: [0x02, 0x08] + extPanId.bigEndianBytes)

        // Network Name (type 0x03): UTF-8, max 16 bytes
        let name: String
        if let networkName, !networkName.isEmpty {
            name = String(networkName.prefix(16))
        } else {
            let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            name = String((0..<16).map { _ in chars.randomElement()! })
        }
        let nameBytes = Array(name.utf8)
        tlvData.append(contentsOf: [0x03, UInt8(nameBytes.count)] + nameBytes)

        // PSKC (type 0x04): 16 random bytes
        var pskc = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, 16, &pskc)
        tlvData.append(contentsOf: [0x04, 0x10] + pskc)

        // Network Key (type 0x05): 16 random bytes
        var networkKey = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, 16, &networkKey)
        tlvData.append(contentsOf: [0x05, 0x10] + networkKey)

        // Mesh Local Prefix (type 0x07): 8 bytes, ULA prefix starting with 0xFD
        var meshPrefix = [UInt8](repeating: 0, count: 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, 8, &meshPrefix)
        meshPrefix[0] = 0xFD // ULA prefix
        tlvData.append(contentsOf: [0x07, 0x08] + meshPrefix)

        // Security Policy (type 0x0C): 4 bytes
        // Default: rotation time 672h, standard flags
        let securityPolicy: UInt32 = (672 << 16) | 0xFF_F8
        tlvData.append(contentsOf: [0x0C, 0x04] + securityPolicy.bigEndianBytes)

        // Active Timestamp (type 0x0E): 8 bytes
        // Seconds since epoch shifted left by 16, with tick=0 and authoritative=1
        let seconds = UInt64(Date().timeIntervalSince1970)
        let timestamp = (seconds << 16) | 1 // authoritative bit set
        tlvData.append(contentsOf: [0x0E, 0x08] + timestamp.bigEndianBytes)

        // Channel Mask (type 0x35): channel page (1) + mask length (1) + mask (4) = 6 bytes
        // Set bits for channels 11-26
        var mask: UInt32 = 0
        for ch in 11...26 {
            mask |= 1 << ch
        }
        tlvData.append(contentsOf: [0x35, 0x06, 0x00, 0x04] + mask.bigEndianBytes)

        return tlvData
    }
}

private extension UInt16 {
    var bigEndianBytes: [UInt8] {
        withUnsafeBytes(of: bigEndian) { Array($0) }
    }
}

private extension UInt32 {
    var bigEndianBytes: [UInt8] {
        withUnsafeBytes(of: bigEndian) { Array($0) }
    }
}

private extension UInt64 {
    var bigEndianBytes: [UInt8] {
        withUnsafeBytes(of: bigEndian) { Array($0) }
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
