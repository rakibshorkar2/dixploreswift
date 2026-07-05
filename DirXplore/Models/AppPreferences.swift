import Foundation
import SwiftData

@Model
final class AppPreferences {
    @Attribute(.unique) var id: UUID
    var accentColorHex: String
    var selectedTheme: String
    var oledMode: Bool
    var maxConcurrentDownloads: Int
    var maxDownloadSpeed: Int64
    var requireAuthOnLaunch: Bool
    var autoLockMinutes: Int
    var privacyBlurEnabled: Bool
    var proxyEnabled: Bool
    var proxyType: String
    var proxyServer: String
    var proxyPort: Int
    var proxyUsername: String
    var proxyPassword: String

    init(
        accentColorHex: String = "007AFF",
        selectedTheme: String = "system",
        oledMode: Bool = false,
        maxConcurrentDownloads: Int = 3,
        maxDownloadSpeed: Int64 = 0,
        requireAuthOnLaunch: Bool = true,
        autoLockMinutes: Int = 5,
        privacyBlurEnabled: Bool = true,
        proxyEnabled: Bool = false,
        proxyType: String = "socks5",
        proxyServer: String = "103.166.253.92",
        proxyPort: Int = 1088,
        proxyUsername: String = "test",
        proxyPassword: String = "test"
    ) {
        self.id = UUID()
        self.accentColorHex = accentColorHex
        self.selectedTheme = selectedTheme
        self.oledMode = oledMode
        self.maxConcurrentDownloads = maxConcurrentDownloads
        self.maxDownloadSpeed = maxDownloadSpeed
        self.requireAuthOnLaunch = requireAuthOnLaunch
        self.autoLockMinutes = autoLockMinutes
        self.privacyBlurEnabled = privacyBlurEnabled
        self.proxyEnabled = proxyEnabled
        self.proxyType = proxyType
        self.proxyServer = proxyServer
        self.proxyPort = proxyPort
        self.proxyUsername = proxyUsername
        self.proxyPassword = proxyPassword
    }

    static func defaults() -> AppPreferences {
        AppPreferences()
    }
}
