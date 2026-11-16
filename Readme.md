# Nami Pairing SDK Demo (iOS Companion App)

This project is a lightweight iOS host application designed to demonstrate the simplest use case of the Nami Pairing SDK. 

Internally, this project is used by the Nami team to test local SDK changes without the overhead of the full Lookout24 application. Externally, it serves as a reference implementation for consumer apps integrating the `NamiPairingFramework`.

## Running the Demo Locally

1. Open `nami companion.xcodeproj`. In the monorepo the root `nami.xcworkspace` also
   contains it; the project builds on its own, which is how CI archives the app.
2. Select the `nami companion` scheme in Xcode.
3. Build and run on an iOS Simulator or physical device.

Command-line build for the simulator:

```bash
xcodebuild build -project "nami companion.xcodeproj" -scheme "nami companion" -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO
```

*Note:* The demo app consumes the `NamiPairing` product of the
[`NamiPairing_iOS`](https://github.com/namiai/NamiPairing_iOS) Swift package, pinned to the exact
version `5.5.0`. To try a locally built `NamiPairingFramework.xcframework` instead, replace the
package product with the built framework in the target's "Frameworks, Libraries, and Embedded
Content" phase and set it to "Embed & Sign".

## Tests

The `nami companionTests` unit tests cover the entity picker tree, the `external-device-ids`
request and its decoding, and the `partner_id` decoding of the session activation. They run
from the `nami companion` scheme:

```bash
xcodebuild test -project "nami companion.xcodeproj" -scheme "nami companion" -destination "platform=iOS Simulator,name=iPhone 17" CODE_SIGNING_ALLOWED=NO
```

## Using the Demo

1. Enter a session code from the partner's application and adjust the client id, template base
   URL, country, language, appearance, measurement system and rooms support if needed. The
   default template base URL is the `v0.16.0` precompiled layouts, the set made for SDK 5.5.0.
2. **Confirm** activates the session and opens the place's device list.
3. The `…` menu presents the SDK flows: adding a single device, the setup guide, settings,
   settings for an entity, Wi-Fi credentials, PIN creation, the system test and entry/exit delays.

### Settings for an entity

**Show settings with parameter** opens a sheet for choosing the zone, room or device that the
settings screen opens with:

- **Entity ID** takes any id, typed or pasted, including one the backend does not map (to see
  the SDK dismiss the screen for an unknown entity).
- Below it the place's zones, rooms and devices are listed with the partner ids that the
  backend's `external-device-ids` mapping points at each one. Tapping an id opens settings with
  it. Ids mapped to entities outside the loaded place get their own section. The sheet reloads
  the place, its devices and the mapping each time it opens.

The partner id is `session_parameters.partner_id` from the companion's own session
activation. When the session has none, the sheet shows no mapping and the SDK dismisses the
settings screen.

## Integration Guide: Using the SDK in Consumer Code

The following steps illustrate how a third-party application integrates the Nami Pairing SDK, as demonstrated in this project.

### 1. Add the Dependency

Add the SDK via Swift Package Manager (SPM) using the distribution repository:
* **URL:** `https://github.com/namiai/NamiPairing_iOS.git`
* **Version:** `5.5.0` or later for `with(entityID:partnerID:)`; this demo pins exactly `5.5.0`

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

With a token store the SDK does not activate a session itself, so it has no partner id of its
own; pass yours to entity-scoped settings (see below).

### 4. Configure the SDK Environment

Define the appearance, language, server environments, and client settings using `NamiSdkConfig`. This configuration is heavily utilized by the Server-Driven UI (SDUI) engine to fetch the correct layout templates.

```swift
let config = NamiSdkConfig(
    baseURL: URL(string: "https://mobile-screens.nami.surf/divkit/v0.16.0/precompiled_layouts")!,
    countryCode: "us",
    measurementSystem: .imperial,
    clientId: "alarm_com_security",
    language: "en-US",
    appearance: .light
)
```

### 5. Present the UI

To start a flow, pass an entry point, the place id and the configuration to `presentEntryPoint`
on your `pairing` instance. It returns the SwiftUI view to show.

```swift
let view = try pairing.presentEntryPoint(
    RemoteTemplateEntrypoint.setupKitGuide,
    placeId: placeId,
    config: config
)
```

#### Supported Entry Points:

* `.settings` - Presents the device/system settings screen.
* `.settings.with(entityID:partnerID:)` - Presents settings with a zone, room or device selected.
* `.setupKitGuide` - Presents the guided flow for setting up a complete kit of devices.
* `.setupDeviceGuide` - Presents the flow for setting up a single device.
* `.updateWifiCredentials` - Presents the flow for updating the devices' Wi-Fi credentials.
* `.settingsEntryExitDelays` - Presents the entry and exit delay settings.
* `.testSystem` - Presents the system test.

#### Entity-scoped settings

`with(entityID:partnerID:)` opens settings with an entity already selected. The SDK asks the
backend's `GET /places/:place_id/external-device-ids` for the place's `external id → internal
URN` table and selects the entity the id maps to. Only keys of that table resolve; internal
URNs and device UIDs do not unless the backend maps them.

The partner id is the external id of your nami client. An app that initializes the SDK with a
token store, as this demo does, must pass it:

```swift
let entrypoint = RemoteTemplateEntrypoint.settings.with(
    entityID: "alarm_dot_com:mz:4f41cbfd-bdb6-4e90-82db-968355de0a31",
    partnerID: partnerId
)
let view = try pairing.presentEntryPoint(entrypoint, placeId: placeId, config: config)
```

Without a partner id, for a partner id the place is not linked to, or for an id the table does
not contain, the SDK dismisses the settings screen.
