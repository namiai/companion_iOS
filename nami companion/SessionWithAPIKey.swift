// Copyright (c) nami.ai

import Combine
import Foundation
import NamiPairingFramework

final class SessionWithAPIKey: NetworkSession {
    // MARK: Lifecycle

    init(session: NetworkSession, apiKey: String) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: Internal

    func publisher(for request: URLRequest, token: AccessToken?) -> AnyPublisher<Data, Error> {
        var newRequest = request
        newRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        return session.publisher(for: newRequest, token: token)
    }

    // MARK: Private

    private let apiKey: String
    private let session: NetworkSession
}
