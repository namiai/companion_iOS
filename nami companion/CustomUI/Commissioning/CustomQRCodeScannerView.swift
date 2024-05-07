//
//  CustomQRCodeScannerView.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 8/4/24.
//

import SwiftUI
import NamiPairingFramework

public struct CustomQRCodeScannerView: View {
    public init(viewModel: QRScanner.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Text("Custom QR Scanner")
            viewModel.undecoratedScannerView
        }
    }
    
    @ObservedObject var viewModel: QRScanner.ViewModel
}

//#Preview {
//    CustomQRCodeScannerView()
//}
