// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - ListWiFiNetworksView

public struct ListWiFiNetworksView: View {
    // MARK: Lifecycle

    public init(viewModel: ListWiFiNetworks.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: ListWiFiNetworks.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(viewModel.state.shouldShowBSSIDWarning ? I18n.Pairing.ListWiFiNetworks.warning.localized : I18n.Pairing.ListWiFiNetworks.header.localized)
                    .padding()

                if viewModel.state.shouldShowProgressView {
                    NamiChatBubble(viewModel.state.shouldShowRetryingNetworks ? I18n.Pairing.ListWiFiNetworks.retryingForNetworks.localized : I18n.Pairing.ListWiFiNetworks.lookingForNetworks.localized)
                        .padding()
                    ProgressView()
                }
                if viewModel.state.shouldShowNoNetworksHint {
                    NamiChatBubble(I18n.Pairing.ListWiFiNetworks.noNetworksFound.localized(with: I18n.Pairing.ListWiFiNetworks.otherNetworkButton.localized))
                        .padding()
                }
                ScrollView {
                    if viewModel.state.shouldShowBSSIDWarning {
                        Text(I18n.Pairing.ListWiFiNetworks.apOutOfReach.localized).frame(alignment: .center)
                    } else {
                        if let userAdded = viewModel.state.userAddedNetwork {
                            WiFiNetworkRowView(network: userAdded, selected: userAdded.ssid == viewModel.state.selectedNetwork?.ssid)
                                .padding(.horizontal)
                        }
                        if let networks = viewModel.state.networks {
                            ForEach(networks, id: \.self) { network in
                                WiFiNetworkRowView(network: network, selected: network.ssid == viewModel.state.selectedNetwork?.ssid)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        viewModel.send(event: .selectNetwork(network))
                                    }
                            }
                        }
                    }
                }
                Spacer()
                if viewModel.state.shouldShowBSSIDWarning {
                    Button(I18n.Pairing.ListWiFiNetworks.refreshButton.localized, action: { viewModel.send(event: .tappedRefreshNetwork) })
                        .buttonStyle(NamiActionButtonStyle(rank: .primary))
                    Button(I18n.Pairing.ListWiFiNetworks.cancelPairingButton.localized, action: { viewModel.send(event: .dismissItself) })
                        .buttonStyle(NamiActionButtonStyle(rank: .secondary))
                } else {
                    Button(I18n.Pairing.ListWiFiNetworks.continueButton.localized, action: { viewModel.send(event: .tappedConfirmSelection) })
                        .disabled(viewModel.state.selectedNetwork == nil || viewModel.state.shouldShowBSSIDWarning)
                        .buttonStyle(NamiActionButtonStyle(rank: .primary))
                    Button(I18n.Pairing.ListWiFiNetworks.otherNetworkButton.localized, action: { viewModel.send(event: .tappedOtherNetwork) })
                        .disabled(viewModel.state.shouldShowBSSIDWarning)
                        .buttonStyle(NamiActionButtonStyle(rank: .secondary))
                }
            }
            .padding()
        }
    }
}
