// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

@main
struct nami_companionApp: App {
    @StateObject var themeManager = ThemeManager(selectedTheme: NamiTheme())
    @StateObject var wordingManager = WordingManager(wordings: NavigationTitleWordings())
    
    let coloredNavAppearance = UINavigationBarAppearance()
    
    init() {
        coloredNavAppearance.configureWithTransparentBackground()
        coloredNavAppearance.backgroundColor = .systemOrange
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
               
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance

    }
    
    var body: some Scene {
        WindowGroup {
            router.buildView()
                .environmentObject(themeManager)
                .environmentObject(wordingManager)
        }
    }
    
    @ObservedObject var router = RootRouter()
}
