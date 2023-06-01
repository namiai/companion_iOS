
import Foundation
import SwiftUI
import NamiPairingFramework

enum DeviceImages {
    static func image(for codeName: String) -> Image {
        if let deviceShape = UIImage(named: codeName.lowercased(), in: nil, with: nil) {
            return Image(uiImage: deviceShape)
        }

        return Image(uiImage: UIImage(named: "unknownmodel", in: Bundle(), with: nil) ?? UIImage())
    }

    func image(for model: NamiDeviceModel) -> Image {
        Self.image(for: model.codeName)
    }
}
