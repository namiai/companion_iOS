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
        }
    }
    
    @ObservedObject var viewModel: EnterWiFiPassword.ViewModel
}
