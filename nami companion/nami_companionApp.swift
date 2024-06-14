// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

@main
struct nami_companionApp: App {
    @StateObject var themeManager = ThemeManager(selectedTheme: CustomTheme())
    @StateObject var wordingManager = WordingManager(wordings: CustomWordings())
    
    var body: some Scene {
        WindowGroup {
            router.buildView()
                .environmentObject(themeManager)
                .environmentObject(wordingManager)
        }
    }
    
    @ObservedObject var router = RootRouter()
}
