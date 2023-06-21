//
//  nami_companionApp.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI
import NamiPairingFramework

@main
struct nami_companionApp: App {
    var body: some Scene {
        WindowGroup {
            router.buildView()
        }
    }
    
    @ObservedObject var router = RootRouter()
}
