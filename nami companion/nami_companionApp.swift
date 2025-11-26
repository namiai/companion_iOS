// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

@main
struct nami_companionApp: App {
    var body: some Scene {
        WindowGroup {
            router.buildView()
                .sheet(item: $router.currentError) { error in
                    ErrorSheetView(error: error, dismiss: {
                        router.clearError()
                    })
                }
        }
    }
    
    @ObservedObject var router = RootRouter()
}
