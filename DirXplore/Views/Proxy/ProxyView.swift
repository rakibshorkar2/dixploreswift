import SwiftUI
import SwiftData

struct ProxyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [AppPreferences]

    @State private var testResult: String?
    @State private var isTesting = false

    init() {
        let config = FetchDescriptor<AppPreferences>()
        _preferences = Query(config)
    }

    private var prefs: AppPreferences? {
        preferences.first
    }

    var body: some View {
        NavigationStack {
            if let prefs = prefs {
                Form {
                    Section("Proxy Configuration") {
                        Toggle("Enable Proxy", isOn: Bindable(prefs).proxyEnabled)

                        Picker("Type", selection: Bindable(prefs).proxyType) {
                            Text("SOCKS5").tag("socks5")
                        }

                        TextField("Server", text: Bindable(prefs).proxyServer)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        TextField("Port", value: Bindable(prefs).proxyPort, format: .number)
                            .keyboardType(.numberPad)

                        TextField("Username", text: Bindable(prefs).proxyUsername)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        SecureField("Password", text: Bindable(prefs).proxyPassword)
                    }

                    Section("Connection") {
                        Button {
                            Task { await testProxyConnection() }
                        } label: {
                            HStack {
                                Text("Test Connection")
                                Spacer()
                                if isTesting {
                                    ProgressView()
                                } else if let result = testResult {
                                    Image(systemName: result == "success" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(result == "success" ? .green : .red)
                                }
                            }
                        }
                        .disabled(isTesting)
                    }
                }
                .navigationTitle("Proxy")
                .alert("Connection Test", isPresented: .constant(testResult != nil && testResult != "success")) {
                    Button("OK") { testResult = nil }
                } message: {
                    if let result = testResult, result != "success" {
                        Text(result)
                    }
                }
            } else {
                ContentUnavailableView("No Preferences", systemImage: "gear", description: Text("Loading settings…"))
            }
        }
    }

    func testProxyConnection() async {
        isTesting = true
        testResult = nil
        guard let prefs = prefs else {
            testResult = "Preferences not loaded"
            isTesting = false
            return
        }
        guard prefs.proxyEnabled else {
            testResult = "Proxy is not enabled"
            isTesting = false
            return
        }

        let config = URLSessionConfiguration.ephemeral
        config.connectionProxyDictionary = [
            kCFNetworkProxiesSOCKSEnable: true,
            kCFNetworkProxiesSOCKSProxy: prefs.proxyServer,
            kCFNetworkProxiesSOCKSPort: prefs.proxyPort,
            kCFStreamPropertySOCKSUser: prefs.proxyUsername,
            kCFStreamPropertySOCKSPassword: prefs.proxyPassword
        ]

        let session = URLSession(configuration: config)
        do {
            let (_, response) = try await session.data(from: URL(string: "https://httpbin.org/ip")!)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                testResult = "success"
            } else {
                testResult = "Unexpected response"
            }
        } catch {
            testResult = "Connection failed: \(error.localizedDescription)"
        }
        isTesting = false
    }
}
