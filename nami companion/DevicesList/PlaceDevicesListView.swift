// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

struct PlaceDevicesListView: View {
    init(viewModel: PlaceDevicesListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let bssid = viewModel.state.bssid {
                    VStack {
                        Text("BSSID Pin: " + bssid.map { String(format: "%02.2hhx", $0) }.joined(separator: ":"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                
                if viewModel.state.devices.isEmpty == false {
                    Button("Delete Thread credentials") {
                        viewModel.deleteThreadCredentials()
                    }
                    
                    List {
                        ForEach(viewModel.state.devices, id: \.id) { device in
                            deviceRow(for: device)
                        }
                    }
                }
            }
            .navigationTitle("Place devices list")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Single Device") {
                            viewModel.presentPairing()
                        }
                        Button("Start Setup Guide") {
                            viewModel.presentSetupGuide()
                        }
                        Button("Show settings") {
                            viewModel.presentSettings()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func deviceRow(for device: Device) -> some View {
        HStack {
            Text(device.type ?? "unknown")
            Spacer()
            if device.type == "thread_widar_sensor" {
                Button {
                    viewModel.presentPositioning(deviceName: device.name, deviceUid: device.uid)
                } label: {
                    Text("Reposition")
                }
            }
        }
        .contextMenu {
            Button(action: {
                viewModel.deleteDevice(deviceId: device.id)
            }) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
    
    @ObservedObject var viewModel: PlaceDevicesListViewModel
}
