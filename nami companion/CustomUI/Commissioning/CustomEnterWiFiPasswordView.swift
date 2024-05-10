// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomEnterWiFiPasswordView: View {
    public init(viewModel: EnterWiFiPassword.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Enter WiFi password")
            TextField("WiFi password", text: Binding(get: {
                viewModel.state.password
            }, set: { value in
                viewModel.state[keyPath: \.password] = value
            }))
            
            Button("Connect", action: { 
                // If the keyboard was dismissed already.
                viewModel.send(event: .confirmPassword)
            })
        }
    }
    
    @ObservedObject var viewModel: EnterWiFiPassword.ViewModel
}
