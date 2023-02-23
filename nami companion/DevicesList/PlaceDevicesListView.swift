//
//  PlaceDevicesListView.swift
//  nami companion
//
//  Created by Yachin Ilya on 23.02.2023.
//

import SwiftUI

struct PlaceDevicesListView: View {
    init(viewModel: PlaceDevicesListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.state.devices.isEmpty == false {
                    List {
                        ForEach(viewModel.state.devices) { device in
                            HStack{
                                Text(device.name)
                                Text(device.model.codeName)
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.state.place.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.state.presentingPairing = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $viewModel.state.presentingPairing) {
            viewModel.updateDevices()
        } content: {
            NavigationView {
                viewModel.buildPairingView()
            }
        }
        
    }
    
    @ObservedObject var viewModel: PlaceDevicesListViewModel
}

struct PlaceDevicesListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDevicesListView(viewModel: PlaceDevicesListViewModel())
    }
}
