// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomPowerOnAndScanningView: View {
    public init(viewModel: PowerOnAndScanning.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("This is custom view for power and scanning")
            
            HStack {
                Text("Searching for device")
                ProgressView()
                    .padding()
            }
        }
    }
    
    @ObservedObject var viewModel: PowerOnAndScanning.ViewModel
}
