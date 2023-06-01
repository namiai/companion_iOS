// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - BluetoothDeviceFoundView

public struct BluetoothDeviceFoundView: View {
    // MARK: Lifecycle

    public init(viewModel: BluetoothDeviceFound.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: BluetoothDeviceFound.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                if let modelTitle = viewModel.state.deviceModel?.productLabel {
                    NamiChatBubble(I18n.Pairing.BluetoothDeviceFound.header1Known.localized(with: modelTitle))
                        .padding()
                } else {
                    NamiChatBubble(I18n.Pairing.BluetoothDeviceFound.header1.localized)
                        .padding()
                }
                NamiChatBubble(I18n.Pairing.BluetoothDeviceFound.header2.localized)
                    .padding()
                ProgressView()
                if let codeName = viewModel.state.deviceModel?.codeName {
                    DeviceImages.image(for: codeName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
