// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomBluetoothUsageHintView: View {
    // MARK: Lifecycle

    public init(viewModel: BluetoothUsageHint.ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Public

    public var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    Text("YO connect to the outlet")
                        .font(.title)
                        .padding([.horizontal, .top])
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Plug must blink like disco ball in 90s")
                        .font(.caption)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(
            Text("Custom BT")
        )
        .onAppear {
            viewModel.send(event: .tapNext)
        }
    }

    // MARK: Internal

    @ObservedObject var viewModel: BluetoothUsageHint.ViewModel
}
