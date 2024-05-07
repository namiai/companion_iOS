// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomInitialScreenView: View {
    public init(viewModel: InitialScreen.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Initial screen of positioning process")
            Button("How to position") {
                viewModel.send(.howToPositionTapped)
            }
        }
    }
    
    @ObservedObject var viewModel: InitialScreen.ViewModel
}
