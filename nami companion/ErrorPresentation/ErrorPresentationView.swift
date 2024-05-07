// Copyright (c) nami.ai

import SwiftUI

struct ErrorPresentationView: View {
    
    init(viewModel: ErrorPresentationViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject var viewModel: ErrorPresentationViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.state.errorMessage)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                viewModel.dismissError()
            } label: {
                Text("Oh, fine")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: 300)
    }
}
