//
//  CustomInitialScreenView.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 2/5/24.
//

import SwiftUI
import NamiPairingFramework

public struct CustomInitialScreenView: View {
    public init(viewModel: InitialScreen.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    @ObservedObject var viewModel: InitialScreen.ViewModel
}

//#Preview {
//    CustomInitialScreenView()
//}
