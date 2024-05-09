// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

@main
struct nami_companionApp: App {
    @StateObject var themeManager = ThemeManager(selectedTheme: CustomTheme())
    
    var body: some Scene {
        WindowGroup {
            router.buildView()
                .environmentObject(themeManager)
        }
    }
    
    @ObservedObject var router = RootRouter()
}
