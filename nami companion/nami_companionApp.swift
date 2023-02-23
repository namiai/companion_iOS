//
//  nami_companionApp.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI
import WebAPI
import TokenStore
import WiFiStorage

@main
struct nami_companionApp: App {
    var body: some Scene {
        WindowGroup {
            router.buildView()
        }
    }
    
    @ObservedObject var router = RootRouter(ApplicationServices())
}

final class ApplicationServices {
    var api: WebAPIProtocol?
    var tokenStore: TokenStore
    var pairingManager: PairingManager?
    private let baseUrl = URL(string: "https://mimizan.nami.surf")!
    private let signUpUrl = URL(string: "https://app.nami.surf/signin")!
    
    init() {
        tokenStore = TokenSecureStorage(server: baseUrl.host()!)
    }
    
    func setupAPI(apiKey: String) -> WebAPIProtocol {
        let api = WebAPI(base: baseUrl, signUpBase: signUpUrl, session: SessionWithAPIKey(session: URLSession.shared, apiKey: apiKey), tokenStore: tokenStore)
        self.api = api
        pairingManager = PairingManager(api: api, wifiStorage: WiFiStorage())
        return api
    }
    
    
}
