// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomEnableBluetoothInSettingsView: View {
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            Text("It seems that Bluetooth is disabled.")
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
