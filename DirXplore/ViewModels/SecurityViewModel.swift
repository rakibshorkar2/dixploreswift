import Foundation
import Observation

@Observable
final class SecurityViewModel {
    var isLocked = true
    var biometricAvailable = false
    var pinSet = false
    var pinEntry = ""
    var pinError: String?

    private let securityManager: SecurityManager

    init(securityManager: SecurityManager) {
        self.securityManager = securityManager
        checkBiometrics()
    }

    func checkBiometrics() {
        biometricAvailable = securityManager.biometricAvailable
        pinSet = securityManager.pinSet
    }

    func authenticateWithBiometrics() async {
        let success = await securityManager.authenticate(reason: "Unlock DirXplore")
        await MainActor.run {
            if success {
                isLocked = false
                pinError = nil
            } else {
                pinError = "Biometric authentication failed"
            }
        }
    }

    func authenticateWithPIN() async {
        guard !pinEntry.isEmpty else {
            pinError = "Please enter your PIN"
            return
        }

        let isValid = await securityManager.validatePIN(pinEntry)
        await MainActor.run {
            if isValid {
                isLocked = false
                pinEntry = ""
                pinError = nil
            } else {
                pinError = "Incorrect PIN"
                pinEntry = ""
            }
        }
    }

    func setPIN(_ pin: String) async {
        guard pin.count >= 4, pin.count <= 8, pin.allSatisfy(\.isNumber) else {
            await MainActor.run { pinError = "PIN must be 4-8 digits" }
            return
        }

        await securityManager.setPIN(pin)
        await MainActor.run {
            pinSet = true
            pinEntry = ""
            pinError = nil
        }
    }

    func lock() {
        isLocked = true
        pinEntry = ""
        pinError = nil
        Task { await securityManager.lock() }
    }

    func unlock() {
        isLocked = false
        pinError = nil
    }
}
