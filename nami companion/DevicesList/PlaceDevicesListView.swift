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
    
    @ObservedObject var viewModel: PlaceDevicesListViewModel
}
