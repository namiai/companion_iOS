//
//  ContentView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI
import WebAPI
import TokenStore

struct SessionCodeView: View {
    @ObservedObject var viewModel: SessionCodeViewModel
    
    init(viewModel: SessionCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            
            Text("Please paste your API key in to be able to communicate with nami API")
                .frame(maxWidth: .infinity, alignment: .leading)
            SecureField("API Key", text: $viewModel.state.apiKey)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
            Text("Please enter the session code acquired from the partner's application.")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("Session Code", text: $viewModel.state.sessionCode)
                .textFieldStyle(.roundedBorder)
            Button("Confirm") {
                viewModel.confirmTapped()
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.state.disableButton)
            .padding()
        }
        .frame(maxWidth: 300)
        .padding()
    }
}

struct SessionCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SessionCodeView(viewModel: SessionCodeViewModel())
    }
}
