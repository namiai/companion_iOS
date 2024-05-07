// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomPositioningCompleteView: View {
    public init(viewModel: PositioningComplete.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Positioning finished")
            Button("Done") {
                viewModel.send(.confirmPositioningComplete)
            }
        }
    }
    
    @ObservedObject var viewModel: PositioningComplete.ViewModel
}
