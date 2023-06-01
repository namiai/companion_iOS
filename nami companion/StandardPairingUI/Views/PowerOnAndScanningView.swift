// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - PowerOnAndScanningView

public struct PowerOnAndScanningView: View {
    // MARK: Lifecycle

    public init(viewModel: PowerOnAndScanning.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: PowerOnAndScanning.ViewModel

    public var body: some View {
        ZStack {
            Color.lowerBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                NamiChatBubble(I18n.Pairing.PowerOnAndScanning.header1.localized)
                    .padding()
                NamiChatBubble(I18n.Pairing.PowerOnAndScanning.header2.localized)
                    .padding()
                if viewModel.state.showsProgressIndicator {
                    ProgressView()
                        .padding()
                }
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
