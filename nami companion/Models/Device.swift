// Copyright (c) nami.ai

import Foundation
import NamiPairingFramework

struct Device {
    let id: NamiDeviceID
    let urn: String
    let name: String
    let type: String?
    let roomId: Int64?
}
