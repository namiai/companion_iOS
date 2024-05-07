// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomAskToConnectView: View {
    public init(viewModel: AskToConnect.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if viewModel.state.doneLoading {
                // For simplicity if it's first device in zone and device supports Thread
                // it will be set up as border router 
                VStack {
                    Text(title(devicesCount: viewModel.state.devicesCount, hasThread: viewModel.state.isThreadDevice))
                        .padding([.horizontal, .top])
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ForEach(
                        description(devicesCount: viewModel.state.devicesCount, hasThread: viewModel.state.isThreadDevice),
                        id: \.self
                    ) { substring in
                        HStack(alignment: .top) {
                            Text("・")
                            Text(substring)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                Spacer()
                Button("Next", action: { viewModel.send(event: .tapNext) })
                    .disabled(viewModel.state.nextTapped)
                    .padding()
            } else {
                HStack {
                    Text("Connecting to device")
                    ProgressView()
                        .padding()
                }
            }
        }
        
    }
    
    @ObservedObject var viewModel: AskToConnect.ViewModel
    
    private func title(devicesCount: Int, hasThread: Bool) -> String {
        switch (devicesCount > 0, hasThread) {
        // First, Thread.
        case (false, true):
            return "Setting up device as border router"
        default:
            return "Setting up device"
        }
    }
    
    private func description(devicesCount: Int, hasThread: Bool) -> [String] {
        switch (devicesCount > 0, hasThread) {
        // Non-first, Thread.
        case (true, true):
            return [
                "Device will join thread network",
                "Use same mobile phone for setting up thread supported devices"
            ]
        // Non-first, WiFi.
        case (true, false):
            return [
                "Will connect to WiFi network with other devices",
                "Recommended distance to access point is 30ft or 30m"
            ]
        // First, Thread.
        case (false, true):
            return [
                "Device will create thread network",
                "Use same mobile phone for setting up other thread support devices"
            ]
        // First, WiFi
        case (false, false):
            return [
                "Recommended distance to access point is 30ft or 30m",
            ]
        }
    }
}
