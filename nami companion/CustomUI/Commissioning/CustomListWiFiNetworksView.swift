// Copyright (c) nami.ai
import SwiftUI
import NamiPairingFramework

public struct CustomListWiFiNetworksView: View {
    public init(viewModel: ListWiFiNetworks.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("List of WiFi networks")
            if let networks = viewModel.state.networks {
                ScrollView {
                    VStack {
                        ForEach(Array(networks.enumerated()), id: \.offset) { item in
                            let i = item.offset
                            let network = item.element
                            VStack {
                                Text(network.ssid)
                                    .foregroundColor(Color.black)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .onTapGesture {
                                        viewModel.send(event: .selectNetwofkAndConfirm(network))
                                    }
                                if i < networks.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    @ObservedObject var viewModel: ListWiFiNetworks.ViewModel
}
