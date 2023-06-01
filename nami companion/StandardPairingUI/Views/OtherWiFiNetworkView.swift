// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - OtherWiFiNetworkView

public struct OtherWiFiNetworkView: View {
    // MARK: Lifecycle

    public init(viewModel: OtherWiFiNetwork.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: OtherWiFiNetwork.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.OtherWiFiNetwork.header.localized)
                    .padding()
                Spacer()
                NamiTextField(placeholder: I18n.Pairing.OtherWiFiNetwork.namePlaceholder.localized, text: Binding(get: {
                    viewModel.state[keyPath: \.networkName]
                }, set: { value in
                    viewModel.state[keyPath: \.networkName] = value
                }), returnKeyType: .done)
                    .padding()
                Button(I18n.General.OK.localized, action: { viewModel.send(event: .didConfirmName) })
                    .buttonStyle(NamiActionButtonStyle(rank: .primary))
                    .disabled(viewModel.state.networkName.isEmpty)
                Button(I18n.Pairing.OtherWiFiNetwork.backButton.localized, action: { viewModel.send(event: .goBack) })
                    .buttonStyle(NamiActionButtonStyle(rank: .secondary))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
