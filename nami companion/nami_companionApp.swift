// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

@main
struct nami_companionApp: App {
    @StateObject var themeManager = ThemeManager(selectedTheme: NamiTheme())
    @StateObject var wordingManager = WordingManager()
    
    var body: some Scene {
        WindowGroup {
            router.buildView()
                .environmentObject(themeManager)
                .environmentObject(wordingManager)
                .sheet(item: $router.currentError) { error in
                    ErrorSheetView(error: error, dismiss: {
                        router.clearError()
                    })
                }
        }
    }
    
    @ObservedObject var router = RootRouter()
}
