// Copyright (c) nami.ai

import NamiPairingFramework
import SwiftUI

// MARK: - QRScannerView

public struct QRScannerView: View {
    // MARK: Lifecycle

    public init(viewModel: QRScanner.ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: QRScanner.ViewModel

    public var body: some View {
        ZStack {
            viewModel.undecoratedScannerView

            Rectangle()
                .fill(Color.lowerBackground)
                .edgesIgnoringSafeArea(.all)
                .mask(cameraHoleMask())

            VStack {
                NamiChatBubble(I18n.QRScanner.whereIsQR.localized)
                    .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
    }

    private func cameraHoleMask() -> some View {
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
            Circle()
                .padding()
                .blendMode(.destinationOut)
        }
    }
}
