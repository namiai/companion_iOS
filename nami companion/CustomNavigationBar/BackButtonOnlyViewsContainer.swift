//
//  BackButtonOnlyViewsContainer.swift
//  nami companion
//
//  Created by Hoang Viet Tran on 25/7/24.
//

import Foundation
import NamiPairingFramework
import StandardPairingUI

public struct BackButtonOnlyViewsContainer: PairingStepsContainer {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var bluetoothUsageHint: (BluetoothUsageHint.ViewModel) -> BluetoothUsageHintView = BluetoothUsageHintView.init
    public var powerOnAndScanning: (PowerOnAndScanning.ViewModel) -> PowerOnAndScanningView = PowerOnAndScanningView.init
    public var enableBluetoothInSettings: () -> EnableBluetoothInSettingsView = EnableBluetoothInSettingsView.init
    public var enableCameraInSettings: () -> EnableCameraInSettingsView = EnableCameraInSettingsView.init
    public var bluetoothDeviceFound: (BluetoothDeviceFound.ViewModel) -> BluetoothDeviceFoundView = BluetoothDeviceFoundView.init
    public var askToConnect: (AskToConnect.ViewModel) -> AskToConnectView = AskToConnectView.init
    public var qrCodeScanner: (QRScanner.ViewModel) -> QRScannerView = QRScannerView.init
    public var listWiFiNetworks: (ListWiFiNetworks.ViewModel) -> ListWiFiNetworksView = ListWiFiNetworksView.init
    public var otherWiFiNetwork: (OtherWiFiNetwork.ViewModel) -> OtherWiFiNetworkView = OtherWiFiNetworkView.init
    public var enterWiFiPassword: (EnterWiFiPassword.ViewModel) -> EnterWiFiPasswordView = EnterWiFiPasswordView.init
    public var finishingSetup: () -> FinishingSetupView = FinishingSetupView.init
    public var howToPosition: (HowToPosition.ViewModel) -> HowToPositionView = HowToPositionView.init
    public var initialPositioningScreen: (InitialScreen.ViewModel) -> InitialScreenView = InitialScreenView.init
    public var positioningGuidance: (PositioningGuidance.ViewModel) -> PositioningGuidanceView = PositioningGuidanceView.init
    public var positioningComplete: (PositioningComplete.ViewModel) -> PositioningCompleteView = PositioningCompleteView.init
    public var positionError: (ErrorScreen.ViewModel) -> ErrorScreenView = ErrorScreenView.init
    public var pairingError: (PairingErrorScreen.ViewModel) -> PairingErrorScreenView = PairingErrorScreenView.init
    public var backButton: () -> CloseButton? = CloseButton.init
}
