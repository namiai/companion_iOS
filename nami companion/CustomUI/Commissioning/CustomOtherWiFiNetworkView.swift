// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomOtherWiFiNetworkView: View {
    public init(viewModel: OtherWiFiNetwork.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Enter WiFi network SSID and password")
            TextField(
                "Network name",
                text: Binding(get: {
                    viewModel.state[keyPath: \.networkName]
                }, set: { value in
                    viewModel.state[keyPath: \.networkName] = value
                })
            )
            .padding([.top, .horizontal])
            .onAppear {
                nameIsEditing = true
            }

            let passwordBinding = Binding(get: {
                viewModel.state.password
            }, set: { value in
                viewModel.state[keyPath: \.password] = value
            })
            TextField(
                "Password",
                text: passwordBinding
            )
            .padding()
            Spacer()
            Button("Connect", action: { viewModel.send(event: .didConfirmName) })
                .disabled(viewModel.state.networkName.isEmpty)
                .padding()
        }
    }
    
    @ObservedObject var viewModel: OtherWiFiNetwork.ViewModel
    @State var nameIsEditing = false
    @State var passwordIsEditing = false
}
