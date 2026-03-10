// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

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
                    List {
                        ForEach(viewModel.state.devices, id: \.id.rawValue) { device in
                            deviceRow(for: device)
                        }
                    }
                } else {
                    Text("Use the menu to start pairing or setup.")
                        .padding()
                    Spacer()
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
                        Divider()
                        Button("Show settings") {
                            viewModel.presentSettings()
                        }
                        Button("Create PIN") {
                            viewModel.presentPinCreation()
                        }
                        Button("System test") {
                            viewModel.presentSystemCheckup()
                        }
                        Button("Entry & Exit delay") {
                            viewModel.presentEntryExitDelays()
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
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                Text(device.type ?? "unknown")
                    .font(.subheadline)
            }
            
            Spacer()
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
