// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomErrorScreenView: View {
    public init(viewModel: ErrorScreen.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Positioning error")
            Spacer()
            VStack {
                Button("Retry") {
                    viewModel.send(.retryPositioning)
                }
                Button("Cancel") {
                    viewModel.send(.cancelPositioning)
                }
            }
        }
    }
    
    @ObservedObject var viewModel: ErrorScreen.ViewModel
}
