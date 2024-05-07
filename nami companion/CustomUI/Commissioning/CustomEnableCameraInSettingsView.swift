// Copyright (c) nami.ai

import SwiftUI

public struct CustomEnableCameraInSettingsView: View {
    public var body: some View {
        VStack {
            Text("Missing camera permissions!")
            Spacer()
            Button("Settings", action: openSettings)
                .buttonStyle(.borderless)
                .padding()
        }
        
    }
    
    private func openSettings() {
        guard
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings)
        else {
            return
        }

        UIApplication.shared.open(settings, completionHandler: nil)
    }
}
