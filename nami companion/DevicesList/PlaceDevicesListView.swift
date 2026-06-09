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
                        Button("Show settings with parameter") {
                            viewModel.state.isEntityPickerPresented = true
                        }
                        Button("Update Wi-Fi credentials") {
                            viewModel.presentUpdateWiFiCredentials()
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
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.state.isEntityPickerPresented },
                set: { viewModel.state.isEntityPickerPresented = $0 }
            )) {
                entityPickerSheet
            }
        }
    }

    @ViewBuilder
    private var entityPickerSheet: some View {
        NavigationView {
            Group {
                if let place = viewModel.state.place {
                    List {
                        ForEach(place.zones, id: \.id) { zone in
                            Section {
                                Button {
                                    viewModel.presentSettings(forEntity: zone.urn)
                                } label: {
                                    Label(zone.name.isEmpty ? "Zone" : zone.name,
                                          systemImage: "square")
                                        .font(.headline)
                                }
                                ForEach(zone.rooms, id: \.id) { room in
                                    Button {
                                        viewModel.presentSettings(forEntity: room.urn)
                                    } label: {
                                        Label(room.name.isEmpty ? "Room" : room.name,
                                              systemImage: "square.split.bottomrightquarter")
                                    }
                                    .padding(.leading, 16)
                                    ForEach(viewModel.state.devices.filter { $0.roomId == room.id }, id: \.id.rawValue) { device in
                                        Button {
                                            viewModel.presentSettings(forEntity: device.urn)
                                        } label: {
                                            Label(device.name.isEmpty ? (device.type ?? "Device") : device.name,
                                                  systemImage: "sensor")
                                                .font(.subheadline)
                                        }
                                        .padding(.leading, 32)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Pick entity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.state.isEntityPickerPresented = false
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
