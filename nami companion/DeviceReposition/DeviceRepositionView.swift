//
//  DeviceRepositionView.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 26/4/24.
//

import SwiftUI

struct DeviceRepositionView: View {
    init(viewModel: DeviceRepositionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("WiDAR device repositioning is needed. Press next to start positioning process.")
                Button { 
                    viewModel.presentPositioning(deviceName: viewModel.state.deviceName, deviceUid: viewModel.state.deviceUid)
                } label: {
                    Text("Next")
                }
            }
        }
    }
    
    @ObservedObject var viewModel: DeviceRepositionViewModel
}
