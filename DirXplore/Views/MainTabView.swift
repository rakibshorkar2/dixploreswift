import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var hapticsManager: HapticsManager
    @EnvironmentObject private var downloadService: DownloadService
    @EnvironmentObject private var torrentService: TorrentService
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: Tab = .browser
    @State private var browserViewModel = BrowserViewModel()
    @State private var crawlerViewModel = CrawlerViewModel()
    @State private var downloadManagerViewModel = DownloadManagerViewModel()
    @State private var torrentViewModel = TorrentViewModel()
    @State private var securityViewModel = SecurityViewModel()

    @Query private var activeDownloads: [DownloadItem]

    private var activeDownloadCount: Int {
        activeDownloads.filter { $0.status == "downloading" }.count
    }

    enum Tab: String, CaseIterable {
        case browser = "Browser"
        case downloads = "Downloads"
        case torrent = "Torrent"
        case favorites = "Favorites"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .browser: "folder"
            case .downloads: "arrow.down.circle"
            case .torrent: "square.and.arrow.down"
            case .favorites: "star"
            case .settings: "gear"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowserView()
                .environment(browserViewModel)
                .environment(crawlerViewModel)
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

            TorrentHubView()
                .environment(torrentViewModel)
                .tabItem {
                    Label(Tab.torrent.rawValue, systemImage: Tab.torrent.icon)
                }
                .tag(Tab.torrent)

            FavoritesView()
                .tabItem {
                    Label(Tab.favorites.rawValue, systemImage: Tab.favorites.icon)
                }
                .tag(Tab.favorites)

            SettingsView()
                .environment(securityViewModel)
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .environment(browserViewModel)
        .environment(crawlerViewModel)
        .environment(downloadManagerViewModel)
        .environment(torrentViewModel)
        .environment(securityViewModel)
    }
}

// MARK: - Stub Views (placeholder until created)

private struct BrowserView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Browser",
                systemImage: "folder",
                description: Text("Browse remote directories.")
            )
        }
    }
}

private struct DownloadsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Downloads",
                systemImage: "arrow.down.circle",
                description: Text("Manage your downloads.")
            )
        }
    }
}

private struct TorrentHubView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "TorrentHub",
                systemImage: "square.and.arrow.down",
                description: Text("Manage your torrents.")
            )
        }
    }
}

// MARK: - ViewModel Stubs

@Observable
final class BrowserViewModel {
    var currentURL: String = ""
    var isLoading = false
}

@Observable
final class CrawlerViewModel {
    var isRunning = false
    var visitedCount = 0
}

@Observable
final class DownloadManagerViewModel {
    var activeCount = 0
}

@Observable
final class TorrentViewModel {
    var activeTorrents: [TorrentItem] = []
}

@Observable
final class SecurityViewModel {
    var isLocked = true
    var biometricType: LABiometryType = .none
}
