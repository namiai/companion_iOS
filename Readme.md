This is the demo application showing the most simple use of nami pairing SDK.

## Work in progress: SDK

The SDK is under developement. It comes in two flavours:
- `Tomonari`: a library performing the pairing steps and not providing the UI.
- `NamiStandardPairingSDK`: a library including Tomonari as a dependency yet provding the default nami UI.

## Current solution: Framework

A ready to use framework includes all the code of `NamiStandardPairingSDK` and also provides the way of getting the session to setup the SDK with only the session code (see partners commissioning API documentation).
To start the pairing first it is required to get the session (`SessionCodeActivateResult`) by calling `StandardPairing.activateSession(code: String)` with the code obtained through the partners commissioning API. With the session object (`SessionCodeActivateResult`) an instance of `StandardPairing` might be initialized. `StandardPairing` exposes `api: WebAPIProtocol`, `wifiStorage: WiFiStorageProtocol`, `sdk: NamiStandardPairingSDK`. Most likely the consumer won't need to have the access to nami mobile API (WebAPI) since all the data required is relayed to the partner's servers via cloud-to-cloud API. WiFi storage is also might not be interesting to the consumer, it is only needded internally to securely store the WiFi credentials in to commission the next device in the same WiFi network faster. The instance of `NamiStandardPairingSDK` is what would be the type to work with in the future version of the SDK/Framework. Pls consider `StandardPairing` class just as a temporary proxy wraping the actual WIP SDK code (written as a Swift Package) to expose the methods in the compiled framework.

## Immediate updates

The SDK is planned to be updated to match the current nami app functionality:
- BSSID pinning to guaranty the devices could communicate on the same channel.
- WiFi networks filtering to remove the multiple appearance of the same SSID in a list.
- WiFi creadentials update allowing the transfer of devices to another network without losing the zone configuration.
- Thread commisioning functionality.

Also the following changes are expected:
- PKCE to eleminate the requirement to hardcode the API Key in framework and prevent it from beeing leaked (now the temporary API Key is used so the framework would cease to work once the updated SDK version is released).
- Removing `StandardPairing` class to be fully substituted with `NamiStandardPairingSDK`.
- Adding the method(s) to `NamiStandardPairingSDK` to allow getting the session from it directly.

## Building the project
Please add `NamiStandardPairingFramework.xcframework` to `nami companion` target under the `General` tab, `Frameworks, Libraries and Embedded content` and set the `Embed` dropdown to `Embed & Sign`.

## Using the `StandardPairing`

The device pairing states might be observed through `var devicePairingState: DevicePairingStatePublisher` of `NamiStandardPairingSDK` (see example of use in `PairingManager.setupSubscription()`). It does not publish every pairing step but rather exposes the crucial states when the consuming app might need to react accordingly. States are following:

- `deviceCommisionedAtCloud(Device, in: PlaceID)`: A record for the newly commisioned device is created in the cloud (but device is not yet fully set up). At this step the SDK consumer might want to store the record locally or keep it until the device is fully set up.

- `deviceOperable(DeviceID)`: Device is fully set up: it confirms that it could connect to wi-fi network with the password provided.

- `deviceDecommissioned(DeviceID)`: In case of a failute or the pairing cancellation after the successful commissioning to the cloud (see `deviceCommisionedAtCloud`) the device record is removed from the cloud. The SDK consumer might want to remove (or discard if not stored locally) the record for the device obtained on `deviceCommisionedAtCloud`. 
        
- `pairingCancelled`: Indicates the abortion of the pairing process when no additional cleanup might be required in consumer's code. E.g. if the pairing cancellation is confirmed and the pairing was stopped at the stage when no additional Device data were yet returned from the cloud.
