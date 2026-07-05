import SwiftUI
import LocalAuthentication

struct SecurityLockView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var hapticsManager: HapticsManager
    @EnvironmentObject private var downloadService: DownloadService
    @EnvironmentObject private var torrentService: TorrentService
    @State private var pin = ""
    @State private var pinError = false
    @State private var biometricsTriggered = false

    private let pinLength = 4

    var body: some View {
        ZStack {
            MainTabView()
                .environmentObject(securityManager)
                .environmentObject(hapticsManager)
                .environmentObject(downloadService)
                .environmentObject(torrentService)

            if securityManager.isLocked {
                lockOverlay
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
                    .zIndex(1)
            }
        }
        .animation(.smooth(duration: 0.35), value: securityManager.isLocked)
        .onAppear {
            if !biometricsTriggered {
                biometricsTriggered = true
                triggerBiometrics()
            }
        }
    }

    // MARK: - Lock Overlay

    private var lockOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                if securityManager.biometricType != .none {
                    Image(systemName: biometricIcon)
                        .font(.system(size: 72))
                        .foregroundStyle(.secondary)
                        .symbolEffect(.bounce, options: .repeating)

                    Text("Unlock")
                        .font(.title2.weight(.medium))
                }

                if securityManager.hasPIN() {
                    pinEntry
                        .padding(.top, 8)
                }

                Spacer()

                if securityManager.biometricType != .none {
                    Button {
                        triggerBiometrics()
                    } label: {
                        Label(biometricLabel, systemImage: biometricIcon)
                            .font(.body.weight(.semibold))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(.regularMaterial, in: .capsule)
                    }
                    .buttonStyle(.plain)
                }

                if !securityManager.hasPIN() && securityManager.biometricType == .none {
                    Button("Tap to Unlock") {
                        securityManager.unlock()
                        hapticsManager.success()
                    }
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(.regularMaterial, in: .capsule)
                }

                Spacer()
                    .frame(height: 40)
            }
            .padding()
        }
    }

    // MARK: - PIN Entry

    private var pinEntry: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                ForEach(0..<pinLength, id: \.self) { index in
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 16, height: 16)
                        .overlay {
                            if index < pin.count {
                                Circle()
                                    .fill(Color.primary)
                                    .frame(width: 10, height: 10)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .modifier(ShakeEffect(animating: pinError && index == pin.count - 1))
                }
            }
            .animation(.default, value: pin.count)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(1...9, id: \.self) { number in
                    pinButton("\(number)") {
                        appendPIN(number)
                    }
                }

                pinButton("") {}

                pinButton("0") {
                    appendPIN(0)
                }

                pinButton("delete.left") {
                    deletePIN()
                }
                .font(.title2)
            }
            .frame(maxWidth: 280)
        }
    }

    private func pinButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if label == "delete.left" {
                    Image(systemName: label)
                } else {
                    Text(label)
                        .font(.title.weight(.medium))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: .circle)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var biometricIcon: String {
        switch securityManager.biometricType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        default: "lock.shield"
        }
    }

    private var biometricLabel: String {
        switch securityManager.biometricType {
        case .faceID: "Use Face ID"
        case .touchID: "Use Touch ID"
        default: "Authenticate"
        }
    }

    private func appendPIN(_ digit: Int) {
        guard pin.count < pinLength else { return }
        pin += "\(digit)"
        hapticsManager.light()

        if pin.count == pinLength {
            validatePIN()
        }
    }

    private func deletePIN() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
        pinError = false
    }

    private func validatePIN() {
        if securityManager.authenticateWithPIN(pin: pin) {
            hapticsManager.success()
        } else {
            hapticsManager.error()
            pinError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                pinError = false
                pin = ""
            }
        }
    }

    @MainActor
    private func triggerBiometrics() {
        guard securityManager.isLocked else { return }
        Task {
            _ = await securityManager.authenticate(reason: "Unlock DirXplore")
            if !securityManager.isLocked {
                hapticsManager.success()
            }
        }
    }
}

// MARK: - Shake Effect

private struct ShakeEffect: GeometryEffect {
    var animating: Bool
    var amplitude: CGFloat = 8
    var frequency: CGFloat = 3

    var animatableData: Bool {
        get { animating }
        set { animating = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard animating else { return ProjectionTransform(.identity) }
        let angle = sin(Date().timeIntervalSinceReferenceDate * frequency * .pi * 2) * amplitude
        return ProjectionTransform(CGAffineTransform(translationX: angle, y: 0))
    }
}
