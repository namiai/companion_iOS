// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - EnableBluetoothInSettingsView

public struct EnableBluetoothInSettingsView: View {

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.EnableBluetoothInSettings.header.localized)
                    .padding()
                Spacer()
                Button(I18n.Pairing.EnableBluetoothInSettings.settings.localized, action: openSettings)
                    .buttonStyle(NamiActionButtonStyle(rank: .primary))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

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
