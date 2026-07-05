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

    init(
        accentColorHex: String = "007AFF",
        selectedTheme: String = "system",
        oledMode: Bool = false,
        maxConcurrentDownloads: Int = 3,
        maxDownloadSpeed: Int64 = 0,
        requireAuthOnLaunch: Bool = true,
        autoLockMinutes: Int = 5,
        privacyBlurEnabled: Bool = true
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
    }

    static func defaults() -> AppPreferences {
        AppPreferences()
    }
}
