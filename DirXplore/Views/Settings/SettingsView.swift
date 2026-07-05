import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var preferencesQuery: [AppPreferences]
    @Environment(\.modelContext) private var modelContext

    private var preferences: AppPreferences {
        if let existing = preferencesQuery.first {
            return existing
        }
        let defaults = AppPreferences.defaults()
        modelContext.insert(defaults)
        try? modelContext.save()
        return defaults
    }

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                downloadsSection
                torrentSection
                streamingSection
                networkSection
                securitySection
                aboutSection
                diagnosticsSection
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section("Appearance") {
            NavigationLink {
                ThemePickerView(preferences: preferences)
            } label: {
                HStack {
                    Label("Theme", systemImage: "sun.max")
                    Spacer()
                    Text(themeLabel)
                        .foregroundStyle(.secondary)
                }
            }

            NavigationLink {
                AccentColorPickerView(preferences: preferences)
            } label: {
                HStack {
                    Label("Accent Color", systemImage: "paintpalette")
                    Spacer()
                    Circle()
                        .fill(accentColor)
                        .frame(width: 22, height: 22)
                }
            }

            Toggle(isOn: Binding(
                get: { preferences.oledMode },
                set: { preferences.oledMode = $0; save() }
            )) {
                Label("OLED Mode", systemImage: "circle.lefthalf.filled")
            }
        }
    }

    // MARK: - Downloads

    private var downloadsSection: some View {
        Section("Downloads") {
            Stepper(value: Binding(
                get: { preferences.maxConcurrentDownloads },
                set: { preferences.maxConcurrentDownloads = $0; save() }
            ), in: 1...10) {
                HStack {
                    Label("Max Concurrent", systemImage: "arrow.up.arrow.down")
                    Spacer()
                    Text("\(preferences.maxConcurrentDownloads)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            NavigationLink {
                DefaultFolderPickerView()
            } label: {
                HStack {
                    Label("Download Folder", systemImage: "folder")
                    Spacer()
                    Text("Downloads")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Label("Max Speed", systemImage: "speedometer")
                Spacer()
                TextField("Unlimited", value: Binding(
                    get: { preferences.maxDownloadSpeed },
                    set: { preferences.maxDownloadSpeed = $0; save() }
                ), format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
            }
        }
    }

    // MARK: - Torrent

    private var torrentSection: some View {
        Section("Torrent") {
            NavigationLink {
                DefaultFolderPickerView()
            } label: {
                HStack {
                    Label("Save Path", systemImage: "square.and.arrow.down")
                    Spacer()
                    Text("Torrents")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Label("Max Upload Speed", systemImage: "arrow.up.circle")
                Spacer()
                TextField("Unlimited", text: .constant(""))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
            }

            HStack {
                Label("Max Download Speed", systemImage: "arrow.down.circle")
                Spacer()
                TextField("Unlimited", text: .constant(""))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
            }

            HStack {
                Label("Global Seed Ratio", systemImage: "arrow.triangle.2.circlepath")
                Spacer()
                Text("2.0")
                    .foregroundStyle(.secondary)
            }

            Toggle(isOn: .constant(false)) {
                Label("Sequential by Default", systemImage: "list.number")
            }
        }
    }

    // MARK: - Streaming

    private var streamingSection: some View {
        Section("Streaming") {
            Picker(selection: .constant("internal")) {
                Text("Internal").tag("internal")
                Text("External").tag("external")
            } label: {
                Label("Preferred Player", systemImage: "play.rectangle")
            }

            Toggle(isOn: .constant(true)) {
                Label("Subtitles Enabled", systemImage: "captions.bubble")
            }

            HStack {
                Label("Default Speed", systemImage: "speedometer")
                Spacer()
                Text("1.0x")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Network

    private var networkSection: some View {
        Section("Network") {
            Toggle(isOn: .constant(false)) {
                Label("Cellular Downloads", systemImage: "antenna.radiowaves.left.and.right")
            }

            Toggle(isOn: .constant(true)) {
                Label("Background Refresh", systemImage: "arrow.clockwise")
            }
        }
    }

    // MARK: - Security

    @State private var showingChangePIN = false

    private var securitySection: some View {
        Section("Security") {
            Toggle(isOn: Binding(
                get: { preferences.requireAuthOnLaunch },
                set: { preferences.requireAuthOnLaunch = $0; save() }
            )) {
                Label("Require Auth on Launch", systemImage: "lock.shield")
            }

            Picker(selection: Binding(
                get: { preferences.autoLockMinutes },
                set: { preferences.autoLockMinutes = $0; save() }
            )) {
                Text("1 min").tag(1)
                Text("5 min").tag(5)
                Text("15 min").tag(15)
                Text("30 min").tag(30)
                Text("Never").tag(0)
            } label: {
                Label("Auto-Lock Timer", systemImage: "timer")
            }

            Toggle(isOn: Binding(
                get: { preferences.privacyBlurEnabled },
                set: { preferences.privacyBlurEnabled = $0; save() }
            )) {
                Label("Privacy Blur", systemImage: "eye.slash")
            }

            Button {
                showingChangePIN = true
            } label: {
                HStack {
                    Label("Change PIN", systemImage: "keypad")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .sheet(isPresented: $showingChangePIN) {
                ChangePINView()
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Build", systemImage: "hammer")
                Spacer()
                Text(buildNumber)
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                CreditsView()
            } label: {
                Label("Icons & Credits", systemImage: "person.3")
            }
        }
    }

    // MARK: - Diagnostics

    private var diagnosticsSection: some View {
        Section {
            NavigationLink {
                DiagnosticsView()
            } label: {
                Label("Diagnostics", systemImage: "chart.bar")
            }
        } header: {
            Text("Diagnostics")
        }
    }

    // MARK: - Helpers

    private var themeLabel: String {
        switch preferences.selectedTheme {
        case "light": "Light"
        case "dark": "Dark"
        default: "System"
        }
    }

    private var accentColor: Color {
        Color(hex: preferences.accentColorHex) ?? .blue
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private func save() {
        try? modelContext.save()
    }
}

// MARK: - Sub-Views

private struct ThemePickerView: View {
    let preferences: AppPreferences
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Button {
                preferences.selectedTheme = "system"
                save()
                dismiss()
            } label: {
                HStack {
                    Label("System", systemImage: "circle.lefthalf.filled")
                    Spacer()
                    if preferences.selectedTheme == "system" {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button {
                preferences.selectedTheme = "light"
                save()
                dismiss()
            } label: {
                HStack {
                    Label("Light", systemImage: "sun.max.fill")
                    Spacer()
                    if preferences.selectedTheme == "light" {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button {
                preferences.selectedTheme = "dark"
                save()
                dismiss()
            } label: {
                HStack {
                    Label("Dark", systemImage: "moon.fill")
                    Spacer()
                    if preferences.selectedTheme == "dark" {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle("Theme")
    }

    private func save() {
        try? modelContext.save()
    }
}

private struct AccentColorPickerView: View {
    let preferences: AppPreferences
    @Environment(\.modelContext) private var modelContext

    let colors: [(name: String, hex: String, color: Color)] = [
        ("Blue", "007AFF", .blue),
        ("Red", "FF3B30", .red),
        ("Green", "34C759", .green),
        ("Orange", "FF9500", .orange),
        ("Purple", "AF52DE", .purple),
        ("Pink", "FF2D55", .pink)
    ]

    var body: some View {
        List {
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                    ForEach(colors, id: \.hex) { item in
                        Button {
                            preferences.accentColorHex = item.hex
                            try? modelContext.save()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 48, height: 48)

                                    if preferences.accentColorHex == item.hex {
                                        Image(systemName: "checkmark")
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(.white)
                                    }
                                }

                                Text(item.name)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Accent Color")
            }
        }
        .navigationTitle("Accent Color")
    }
}

private struct DefaultFolderPickerView: View {
    var body: some View {
        List {
            Text("Folder picker coming soon")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Default Folder")
    }
}

private struct ChangePINView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pin = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Enter new PIN")
                    .font(.headline)
                SecureField("PIN", text: $pin)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 200)
                Button("Save") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pin.count < 4)
            }
            .padding()
            .navigationTitle("Change PIN")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct CreditsView: View {
    var body: some View {
        List {
            Text("Icons provided by SF Symbols")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Credits")
    }
}

// MARK: - Color Hex Extension

private extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let value = UInt64(hex, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
