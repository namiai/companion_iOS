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

struct PlaceDevicesListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDevicesListView(viewModel: PlaceDevicesListViewModel())
    }
}
