//
//  PlaceDevicesListView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI
import NamiPairingFramework
import StandardPairingUI

struct PlaceDevicesListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var wordingManager: WordingManager
    
    init(viewModel: PlaceDevicesListViewModel) {
        self.viewModel = viewModel
    }
    
    @State private var selectedTheme: String = "Custom"
    @State private var selectedWording: String = "Default"
    
    private let themes = ["Nami", "Custom"]
    private let wordings = ["Default", "Custom"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Theme picker
                Picker("Select Theme", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedTheme) { newTheme in
                    switch newTheme {
                    case "Nami":
                        themeManager.setTheme(NamiTheme())
                    case "Custom":
                        themeManager.setTheme(CustomTheme())
                    default:
                        break
                    }
                }
                .padding()

                // Wording picker
                Picker("Select Wording", selection: $selectedWording) {
                    ForEach(wordings, id: \.self) { wording in
                        Text(wording).tag(wording)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedWording) { newWording in
                    switch newWording {
                    case "Default":
                        wordingManager.resetWordings()
                    case "Custom":
                        wordingManager.setWordings(CustomWordings())
                    default:
                        break
                    }
                }
                .padding()
                
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
