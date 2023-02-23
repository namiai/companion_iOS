//
//  ErrorPresentationView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

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

struct ErrorPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorPresentationView(viewModel: ErrorPresentationViewModel())
    }
}
