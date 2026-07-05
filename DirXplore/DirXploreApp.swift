import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.dirxplore", category: "App")

@main
struct DirXploreApp: App {
    let container: ModelContainer
    @State private var securityManager = SecurityManager()
    @State private var hapticsManager = HapticsManager()
    @State private var downloadService = DownloadService()
    @State private var torrentService = TorrentService()

    init() {
        let schema = Schema([
            DownloadItem.self,
            TorrentItem.self,
            HistoryItem.self,
            FavoriteItem.self,
            AppPreferences.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            SecurityLockView()
                .environment(securityManager)
                .environment(hapticsManager)
                .environment(downloadService)
                .environment(torrentService)
                .modelContainer(container)
                .onAppear {
                    Task { await checkInitialAuth() }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhase(newPhase)
                }
        }
    }

    @Environment(\.scenePhase) private var scenePhase

    private func checkInitialAuth() async {
        let prefs = try? await container.mainContext.fetch(
            FetchDescriptor<AppPreferences>()
        ).first

        if prefs?.requireAuthOnLaunch == true {
            await securityManager.lock()
        }
    }

    private func handleScenePhase(_ phase: ScenePhase) {
        Task {
            switch phase {
            case .active:
                if securityManager.isLocked {
                    let reason = "Unlock DirXplore"
                    let ok = await securityManager.authenticate(reason: reason)
                    if !ok {
                        logger.warning("Biometric authentication failed on return")
                    }
                }
            case .background, .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
