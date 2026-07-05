import UIKit
import SwiftUI

@MainActor
final class HapticsManager {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    func light() {
        lightImpact.impactOccurred()
    }

    func medium() {
        mediumImpact.impactOccurred()
    }

    func heavy() {
        heavyImpact.impactOccurred()
    }

    func success() {
        notification.notificationOccurred(.success)
    }

    func error() {
        notification.notificationOccurred(.error)
    }

    func warning() {
        notification.notificationOccurred(.warning)
    }

    func selection() {
        selection.selectionChanged()
    }
}
