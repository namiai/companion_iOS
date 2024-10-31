import Foundation
import Security
import NamiPairingFramework

final public class KeychainWiFiStorage: PairingWiFiStorageProtocol {

    public init() {}

    final public func save(password: String?, for networkSSID: String) {
        guard let password = password else { return }
        let passwordData = Data(password.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: networkSSID,
            kSecValueData as String: passwordData
        ]
        
        SecItemDelete(query as CFDictionary) // Delete if existing
        SecItemAdd(query as CFDictionary, nil)
    }

    final public func password(for networkSSID: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: networkSSID,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }

    final public func removeAll() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        SecItemDelete(query as CFDictionary)
    }
}
