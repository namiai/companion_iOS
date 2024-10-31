import NamiPairingFramework

final public class KeychainThreadDatasetStorage: ThreadSecureStorageProtocol {

    public static func storeOrUpdate(with data: Data, at key: String, server: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: server,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // Delete if existing
        SecItemAdd(query as CFDictionary, nil)
    }

    public static func retrieve(at key: String, server: String) -> Result<Data, NamiPairingFramework.InMemoryThreadDatasetStorage.Thread_SecureStorageError> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: server,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return .failure(.cantRetrieve)
        }
        
        return .success(data)
    }

    public static func delete(at key: String, server: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: server
        ]
        SecItemDelete(query as CFDictionary)
    }
}
