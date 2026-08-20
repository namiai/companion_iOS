# Nami Pairing SDK Demo (iOS Companion App)

This project is a lightweight iOS host application designed to demonstrate the simplest use case of the Nami Pairing SDK. 

Internally, this project is used by the Nami team to test local SDK changes without the overhead of the full Lookout24 application. Externally, it serves as a reference implementation for consumer apps integrating the `NamiPairingFramework`.

## Running the Demo Locally

1. Open the monorepo workspace at `nami.xcworkspace`.
2. Select the `nami companion` scheme in Xcode.
3. Build and run on an iOS Simulator or physical device.

*Note:* The demo app links against the local `NamiPairingFramework`. If you are testing local framework changes, ensure the XCFramework is compiled and correctly embedded in the target's "Frameworks, Libraries, and Embedded Content" phase.

## Integration Guide: Using the SDK in Consumer Code

The following steps illustrate how a third-party application integrates the Nami Pairing SDK, as demonstrated in this project.

### 1. Add the Dependency

Add the SDK via Swift Package Manager (SPM) using the distribution repository:
* **URL:** `https://github.com/namiai/NamiPairing_iOS.git`
* **Version:** `v4.0.1` and above

### 2. Import the Frameworks

In the file where you plan to initialize and present the SDK, import the required modules:

```swift
import NamiPairingFramework
```

### 3. Initialize the SDK

The SDK requires the API base URL, a token store carrying the session tokens, and a secure
storage provider for Thread datasets.

*Important:* The SDK instance should be created once and reused throughout the app's lifetime. The same instance can be used to present multiple screens and entry points.

```swift
// Instantiate the pairing SDK
let pairing = NamiPairing(
    baseURL: baseUrl,
    tokenStore: tokenStore,
    threadSecureStorage: KeychainThreadDatasetStorage.self
)
```

### 4. Configure the SDK Environment

Define the appearance, language, server environments, and client settings using `NamiSdkConfig`. This configuration is heavily utilized by the Server-Driven UI (SDUI) engine to fetch the correct layout templates.

```swift
let config = NamiSdkConfig(
    baseURL: URL(string: "https://mobile-screens.nami.surf/divkit/v0.2.0/precompiled_layouts")!,
    countryCode: "us",
    measurementSystem: .imperial,
    clientId: "alarm_com_security",
    language: "en-US",
    appearance: .light
)
```

### 5. Present the UI

To start a flow, provide the configuration and call `presentEntryPoint` on your `pairing` instance. 

```swift
// Present the template
pairing.presentEntryPoint(
    entrypoint: .setupKitGuide, 
    config: config, 
    pairingSteps: ViewsContainer()
)
```

#### Supported Entry Points:

* `.settings` - Presents the device/system settings screen.
* `.setupKitGuide` - Presents the guided flow for setting up a complete kit of devices.
* `.setupDeviceGuide` - Presents the flow for setting up a single device.