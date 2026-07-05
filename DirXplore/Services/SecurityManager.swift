import Foundation
import LocalAuthentication
import CryptoKit
import OSLog

private let logger = Logger(subsystem: "com.dirxplore", category: "Security")

@MainActor
final class SecurityManager {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLocked = true
    private(set) var biometricType: LABiometryType = .none

    private let keychainService = "com.dirxplore.security"
    private let pinKey = "app_pin"

    init() {
        checkBiometricType()
    }

    func lock() {
        isAuthenticated = false
        isLocked = true
        logger.info("App locked")
    }

    func unlock() {
        isAuthenticated = true
        isLocked = false
        logger.info("App unlocked")
    }

    func authenticate(reason: String = "Authenticate to access DirXplore") async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            logger.warning("Biometrics not available: \(error?.localizedDescription ?? "unknown")")
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            if success {
                unlock()
            }
            return success
        } catch {
            logger.error("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }

    func authenticateWithPIN(pin: String) -> Bool {
        guard let storedHash = retrievePINHash() else {
            logger.warning("No PIN set")
            return false
        }
        let inputHash = hashPIN(pin)
        let match = inputHash == storedHash
        if match { unlock() }
        return match
    }

    func setPIN(_ pin: String) {
        let hash = hashPIN(pin)
        storePINHash(hash)
        logger.info("PIN set")
    }

    func hasPIN() -> Bool {
        retrievePINHash() != nil
    }

    func clearPIN() {
        deletePINHash()
        logger.info("PIN cleared")
    }

    // MARK: - Private

    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }
        biometricType = context.biometryType
    }

    private func hashPIN(_ pin: String) -> String {
        guard let data = pin.data(using: .utf8) else { return "" }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func storePINHash(_ hash: String) {
        guard let hashData = hash.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecValueData as String: hashData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrievePINHash() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deletePINHash() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
