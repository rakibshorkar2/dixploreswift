import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(SecurityManager.self) private var securityManager
    @Environment(HapticsManager.self) private var hapticsManager
    @Environment(DownloadService.self) private var downloadService
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: Tab = .browser
    @State private var browserViewModel = BrowserViewModel()
    @State private var downloadManagerViewModel = DownloadManagerViewModel()
    @State private var securityViewModel = SecurityViewModel()

    private var activeDownloadCount: Int {
        (try? modelContext.fetch(FetchDescriptor<DownloadItem>(predicate: #Predicate { $0.status == "downloading" })).count) ?? 0
    }

    enum Tab: String, CaseIterable {
        case browser = "Browser"
        case downloads = "Downloads"
        case proxy = "Proxy"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .browser: "folder"
            case .downloads: "arrow.down.circle"
            case .proxy: "network.badge.shield.half.filled"
            case .settings: "gear"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowserView()
                .environment(browserViewModel)
                .tabItem {
                    Label(Tab.browser.rawValue, systemImage: Tab.browser.icon)
                }
                .tag(Tab.browser)

            DownloadsView()
                .environment(downloadManagerViewModel)
                .tabItem {
                    Label(Tab.downloads.rawValue, systemImage: Tab.downloads.icon)
                }
                .tag(Tab.downloads)
                .badge(activeDownloadCount)

            ProxyView()
                .tabItem {
                    Label(Tab.proxy.rawValue, systemImage: Tab.proxy.icon)
                }
                .tag(Tab.proxy)

            SettingsView()
                .environment(securityViewModel)
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .environment(browserViewModel)
        .environment(downloadManagerViewModel)
        .environment(securityViewModel)
    }
}
