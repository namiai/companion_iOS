//
//  CustomEnterWiFiPassworView.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 8/4/24.
//

import SwiftUI
import NamiPairingFramework

public struct CustomEnterWiFiPasswordView: View {
    public init(viewModel: EnterWiFiPassword.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    @ObservedObject var viewModel: EnterWiFiPassword.ViewModel
}

//#Preview {
//    CustomEnterWiFiPasswordView()
//}
