// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomPairingErrorView: View {
    public init(viewModel: PairingErrorScreen.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Error occurred:")
            Text(viewModel.state.error.localizedDescription)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.top, 4)
            if viewModel.state.actions.isEmpty == false {
                ForEach(0..<viewModel.state.actions.count, id: \.self, content: buttonForAction)
            }
        }
        .padding()
    }
    
    @ObservedObject var viewModel: PairingErrorScreen.ViewModel
    
    private func buttonForAction(at index: Int) -> some View {
        let action = viewModel.state.actions[index]
        return Button(titleForAction(action), action: { viewModel.send(event: .didChooseAction(action)) })
            .disabled(viewModel.state.chosenAction != nil)
    }

    private func titleForAction(_ action: Pairing.ActionOnError) -> String {
        switch action {
        case .tryAgain:
            return "Try again"
        case .restart:
            return "Restart"
        case .ignore:
            return "Ignore"
        }
    }
}
