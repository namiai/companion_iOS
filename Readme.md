This is the demo application showing the most simple use of nami pairing SDK.

## Work in progress: SDK

The SDK is under developement. It comes in two flavours:
- `NamiPairingFramework`: a framework performing the pairing steps and not providing the UI.
- `StandardPairingUI`: a framework bringing the default nami UI.

## Building the project
Please add 
- `NamiPairingFramework.xcframework` to `nami companion` target under the `General` tab, `Frameworks, Libraries and Embedded content` and set the `Embed` dropdown to `Embed & Sign`.
- `StandardPairingUI` to `nami companion` target under the `General` tab, `Frameworks, Libraries and Embedded content` and set the `Embed` dropdown to `Embed & Sign`.
There's also another way to use the packages: start by adding provided `StandardPairingUI_iOS-example_code_w_framework` code as local Swift Package by selecting `nami companion` project, `Package Dependencies`, `+`, `Add Local...`. Please check `StandardPairingUI_iOS-example_code_w_framework` to be advised where to add `NamiPairingFramework.xcframework`.

## How to use SDK
Please refer to the provided `Pairing_SDK.pdf` for more details and use examples.
