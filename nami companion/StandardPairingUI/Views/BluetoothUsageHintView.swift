// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - BluetoothUsageHintView

public struct BluetoothUsageHintView: View {
    // MARK: Lifecycle

    public init(viewModel: BluetoothUsageHint.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: BluetoothUsageHint.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.BluetoothUsageHint.header.localized)
                    .padding(.horizontal)
                Spacer()
                Button(I18n.Pairing.BluetoothUsageHint.confirm.localized, action: { viewModel.send(event: .tapNext) })
                    .disabled(viewModel.state.nextTapped)
                    .buttonStyle(NamiActionButtonStyle(rank: .primary))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
