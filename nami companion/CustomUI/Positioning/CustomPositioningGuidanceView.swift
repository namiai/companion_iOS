// Copyright (c) nami.ai

import SwiftUI
import NamiPairingFramework

public struct CustomPositioningGuidanceView: View {
    public init(viewModel: PositioningGuidance.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Positioning status and signal quality")
            let quality = viewModel.state.positioningQuality

            HStack {
                switch quality {
                case .unknown:
                    ProgressView().frame(width: 16, height: 16)
                    Text("Checking status").foregroundColor(Color.gray)
                case .poor:
                    Circle().fill(Color.red).frame(width: 16, height: 16)
                    Text("Mispositioned").foregroundColor(Color.red)
                case .degraded:
                    Circle().fill(Color.yellow).frame(width: 16, height: 16)
                    Text("Getting better").foregroundColor(Color.yellow)
                case .good:
                    Circle().fill(Color.green).frame(width: 16, height: 16)
                    Text("Optimized").foregroundColor(Color.green)
                }
            }
            
            Spacer()
            
            VStack {
                Button("Finish") {
                    viewModel.send(.wantFinishTapped)
                }
                .disabled(viewModel.state.canNotFinish)

                Button("Cancel") {
                    viewModel.send(.wantCancelTapped)
                }
                .disabled(viewModel.state.canNotCancel)
            }
            .padding(.vertical)
        }
    }
    
    @ObservedObject var viewModel: PositioningGuidance.ViewModel
}
