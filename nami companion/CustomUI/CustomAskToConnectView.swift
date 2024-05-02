//
//  CustomAskToConnecView.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 8/4/24.
//

import SwiftUI
import NamiPairingFramework

public struct CustomAskToConnectView: View {
    public init(viewModel: AskToConnect.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    @ObservedObject var viewModel: AskToConnect.ViewModel
}

//#Preview {
//    CustomAskToConnectView()
//}