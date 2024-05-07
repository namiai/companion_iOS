// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import DeviceConnections

public struct CustomBluetoothDeviceFoundView: View {
    public init(viewModel: BluetoothDeviceFound.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if let deviceModel = viewModel.state.deviceModel {
                if viewModel.state.deviceNameConfirmed {
                    // We can display deviceName and image based on deviceModel.codeName
                    HStack {
                        ProgressView()
                            .padding()
                        Text("\(deviceModel.codeName)")
                    }
                } else {
                    AnyView(askToName(model: deviceModel))
                }
            } else {
                HStack {
                    Text("Device discovered")
                    ProgressView()
                        .padding()
                }
            }
        }
    }
    
    @ObservedObject var viewModel: BluetoothDeviceFound.ViewModel
    @State var deviceName = ""
    
    private func askToName(model: DeviceConnections.NamiDeviceModel) -> some View {
        VStack {
            Text("Give device a name")
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(viewModel.state.deviceName, text: $deviceName)
                .padding(.horizontal)
                .padding(.top, 32)
                .frame(maxWidth: .infinity)
            Spacer()
            Button("Next") {
                viewModel.send(event: .deviceNameConfirmed(deviceName))
            }
            .disabled(deviceName.isEmpty)
            .padding([.bottom, .horizontal])
        }
    }
}
