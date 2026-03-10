// Copyright (c) nami.ai

import SwiftUI

struct DeviceRepositionView: View {
    init(viewModel: DeviceRepositionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("WiDAR device repositioning is needed.")
                    .padding(.horizontal)
                Spacer()
                Button { 
                    if let deviceName = viewModel.state.device?.name {
                        viewModel.presentPositioning(deviceName: deviceName, deviceUid: "")
                    }
                } label: {
                    Text("Start positioning")
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ObservedObject var viewModel: DeviceRepositionViewModel
}
