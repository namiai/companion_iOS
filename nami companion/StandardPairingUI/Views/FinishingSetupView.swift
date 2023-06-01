// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - FinishingSetupView

public struct FinishingSetupView: View {

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.FinishingSetup.header.localized)
                    .padding()
                Spacer()
            }
            .padding()

            VStack {
                Spacer()
                PongView()
                    .frame(maxHeight: 300)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
