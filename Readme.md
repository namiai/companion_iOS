This is the demo application showing the most simple use of nami pairing SDK.

To get started with the SDK:  

Add SPM dependency to your project - https://github.com/namiai/NamiPairing_iOS.git, v4.0.0 and above

Import frameworks:
```
import NamiPairingFramework
import StandardPairingUI
```
Init the pairing SDK:
```
let pairing = try NamiPairing<ViewsContainer>(
    sessionCode: sessionCode,
    wifiStorage: InMemoryWiFiStorage(),
    threadDatasetStore: InMemoryThreadDatasetStorage.self
)
```
SDK instance should be reused during the app lifetime. Same instance can be used to present multiple screens / entrypoints  
Present the template
```
let config = NamiSdkConfig(
            baseURL: URL(string:"https://mobile-screens.nami.surf/divkit/v0.2.0/precompiled_layouts")!,
            countryCode: "us",
            measurementSystem: .imperial,
            clientId: "alarm_com_security",
            language: "en-US",
            appearance: .light
        )
pairing.presentEntryPoint(entrypoint: .setupKitGuide, config: config, pairingSteps: ViewsContainer())
```
Supported entrpoints:  
`.settings` - Settings screen  
`.setupKitGuide` - Setup guide (kits)  
`.setupDeviceGuide` - Setup a single device
