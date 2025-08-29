// Copyright (c) nami.ai

import Foundation
import NamiPairingFramework

struct Device {
    let id: DeviceID
    let uid: DeviceUniversalID
    let name: String
    let type: String?
    let roomId: String?
    
    init(from apiDevice: some DeviceProtocol) {
        self.id = apiDevice.id
        self.uid = apiDevice.uid
        self.name = apiDevice.name
        self.type = apiDevice.model.codeName
        self.roomId = String(apiDevice.roomId)
    }
} 
