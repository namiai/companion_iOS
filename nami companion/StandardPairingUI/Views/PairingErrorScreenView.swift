// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - PairingErrorScreenView

public struct PairingErrorScreenView: View {
    // MARK: Lifecycle

    public init(viewModel: PairingErrorScreen.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: PairingErrorScreen.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiErrorChatBubble(I18n.Pairing.ErrorScreen.errorOccurred.localized(with: viewModel.state.error.localizedDescription))
                    .padding(.horizontal)
                Spacer()
                if viewModel.state.actions.isEmpty == false {
                    ForEach(0..<viewModel.state.actions.count, id: \.self, content: buttonForAction)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    private func buttonForAction(at index: Int) -> some View {
        let action = viewModel.state.actions[index]
        return Button(titleForAction(action).localized, action: { viewModel.send(event: .didChooseAction(action)) })
            .disabled(viewModel.state.chosenAction != nil)
            .buttonStyle(NamiActionButtonStyle(rank: index == 0 ? .primary : .secondary))
    }

    private func titleForAction(_ action: Pairing.ActionOnError) -> LocalizedKey {
        switch action {
        case .tryAgain:
            return I18n.Pairing.ErrorScreen.actionTryAgain
        case .restart:
            return I18n.Pairing.ErrorScreen.actionRestart
        case .ignore:
            return I18n.Pairing.ErrorScreen.actionIgnore
        }
    }
}
