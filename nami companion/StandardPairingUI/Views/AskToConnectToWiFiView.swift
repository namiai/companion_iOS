// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

// MARK: - AskToConnectToWiFiView

public struct AskToConnectToWiFiView: View {
    // MARK: Lifecycle

    public init(viewModel: AskToConnectToWiFi.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: AskToConnectToWiFi.ViewModel

    public var body: some View {
        ZStack {
                        Color.lowerBackground
                            .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.AskToConnectToWiFi.header.localized)
                    .padding()
                if viewModel.state.devicesCount > 1 {
                    if viewModel.state.zonesCount > 1, let zoneName = viewModel.state.zoneName {
                        NamiChatBubble(I18n.Pairing.AskToConnectToWiFi.useSameWiFiAsZone.localized(with: zoneName))
                            .padding()
                    } else {
                        NamiChatBubble(I18n.Pairing.AskToConnectToWiFi.useSameWiFi.localized)
                            .padding()
                    }
                }
                Spacer()
                Button(I18n.General.next.localized, action: { viewModel.send(event: .tapNext) } )
                    .buttonStyle(NamiActionButtonStyle())
                    .disabled(viewModel.state.nextTapped)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
