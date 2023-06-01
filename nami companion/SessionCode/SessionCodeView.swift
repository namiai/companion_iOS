//
//  ContentView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI
import NamiPairingFramework

struct SessionCodeView: View {
    @ObservedObject var viewModel: SessionCodeViewModel
    
    init(viewModel: SessionCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.state.buttonTapped {
                ProgressView()
            } else {
                Text("Please enter the session code acquired from the partner's application.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Session Code", text: $viewModel.state.sessionCode)
                    .textFieldStyle(.roundedBorder)
                Text("Please enter the Room ID where to pair the devices.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Room ID", text: $viewModel.state.roomId)
                    .textFieldStyle(.roundedBorder)
                Button("Confirm") {
                    viewModel.confirmTapped()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.state.disableButton)
                .padding()
            }
        }
        .frame(maxWidth: 300)
        .padding()
    }
}
