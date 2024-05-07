// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomHowToPositionView: View {
    public init(viewModel: HowToPosition.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("How to re-position device with some fancy animation")
            Button("Next") {
                viewModel.send(.startPositioningTapped)
            }
        }
    }
    
    @ObservedObject var viewModel: HowToPosition.ViewModel
}
