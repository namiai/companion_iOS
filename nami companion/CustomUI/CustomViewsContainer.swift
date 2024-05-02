//
//  CustomUIViewsContainer.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 8/4/24.
//

import Foundation
import SwiftUI
import NamiPairingFramework

public struct CustomViewsContainer: PairingStepsContainer {
    // MARK: Lifecycle
    public init() {}
    
    // MARK: Public
    public var bluetoothUsageHint: (BluetoothUsageHint.ViewModel) -> CustomBluetoothUsageHintView = CustomBluetoothUsageHintView.init
    public var powerOnAndScanning: (PowerOnAndScanning.ViewModel) -> CustomPowerOnAndScanningView = CustomPowerOnAndScanningView.init
    public var enableBluetoothInSettings: () -> CustomEnableBluetoothInSettingsView = CustomEnableBluetoothInSettingsView.init
    public var bluetoothDeviceFound: (BluetoothDeviceFound.ViewModel) -> CustomBluetoothDeviceFoundView = CustomBluetoothDeviceFoundView.init
    public var askToConnect: (AskToConnect.ViewModel) -> CustomAskToConnectView = CustomAskToConnectView.init
    public var qrCodeScanner: (QRScanner.ViewModel) -> CustomQRCodeScannerView = CustomQRCodeScannerView.init
    public var listWiFiNetworks: (ListWiFiNetworks.ViewModel) -> CustomListWiFiNetworksView = CustomListWiFiNetworksView.init
    public var otherWiFiNetwork: (OtherWiFiNetwork.ViewModel) -> CustomOtherWiFiNetworkView = CustomOtherWiFiNetworkView.init
    public var enterWiFiPassword: (EnterWiFiPassword.ViewModel) -> CustomEnterWiFiPasswordView = CustomEnterWiFiPasswordView.init
    public var finishingSetup: () -> CustomFinishingSetupView = CustomFinishingSetupView.init
    public var howToPosition: (HowToPosition.ViewModel) -> CustomHowToPositionView = CustomHowToPositionView.init
    public var initialPositioningScreen: (InitialScreen.ViewModel) -> CustomInitialScreenView = CustomInitialScreenView.init
    public var positioningGuidance: (PositioningGuidance.ViewModel) -> CustomPositioningGuidanceView = CustomPositioningGuidanceView.init
    public var positioningComplete: (PositioningComplete.ViewModel) -> CustomPositioningCompleteView = CustomPositioningCompleteView.init
    public var positionError: (ErrorScreen.ViewModel) -> CustomErrorScreenView = CustomErrorScreenView.init
    public var pairingError: (PairingErrorScreen.ViewModel) -> CustomPairingErrorView = CustomPairingErrorView.init
    public var backButton: () -> CustomBackButtonView? = CustomBackButtonView.init
}
