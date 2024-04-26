//
//  PlaceDevicesListView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

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
                    Text("BSSID Pin: " + bssid.map{ String(format: "%02.2hhx", $0) }.joined(separator: ":"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                if viewModel.state.devices.isEmpty == false {
                    List {
                        ForEach(viewModel.state.devices, id: \.id) { device in
                            HStack{
                                Text(device.model.codeName)
                                Spacer()
                                if device.model.codeName == "thread_widar_sensor" {
                                    Button { 
                                        viewModel.presentPositioning(deviceName: device.name, deviceUid: device.uid)
                                    } label : {
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
                    }
                }
            }
            .navigationTitle("Place devices list")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.presentPairing()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        
    }
    
    @ObservedObject var viewModel: PlaceDevicesListViewModel
}
