import Foundation
import Observation

@Observable
final class CrawlerViewModel {
    var isRunning = false
    var isPaused = false
    var rootURL: URL?
    var maxDepth = 3
    var excludeExtensions: [String] = []
    var excludeFolders: [String] = []
    var discoveredFolders = 0
    var visitedCount = 0
    var estimatedRemaining = 0
    var discoveredURLs: [URL] = []

    private let crawlerService: CrawlerService
    private var crawlTask: Task<Void, Never>?
    private var progressContinuation: Task<Void, Never>?

    init(crawlerService: CrawlerService) {
        self.crawlerService = crawlerService
    }

    func startCrawl() {
        guard let rootURL, !isRunning else { return }

        isRunning = true
        isPaused = false
        visitedCount = 0
        discoveredFolders = 0
        estimatedRemaining = 0
        discoveredURLs = []
        errorMessage = nil

        crawlTask = Task { [weak self] in
            guard let self else { return }

            await crawlerService.startCrawl(
                rootURL: rootURL,
                maxDepth: maxDepth,
                excludeExtensions: excludeExtensions,
                excludeFolders: excludeFolders
            )

            await MainActor.run {
                self.isRunning = false
                self.discoveredURLs = await self.crawlerService.discoveredURLs()
                self.discoveredFolders = self.discoveredURLs.filter { $0.hasDirectoryPath }.count
            }
        }

        progressContinuation = Task { [weak self] in
            guard let self else { return }

            for await progress in crawlerService.progressStream {
                await MainActor.run {
                    self.visitedCount = progress.visited
                    self.estimatedRemaining = progress.remaining
                }
            }
        }
    }

    func pauseCrawl() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        Task { await crawlerService.pause() }
    }

    func resumeCrawl() {
        guard isRunning, isPaused else { return }
        isPaused = false
        Task { await crawlerService.resume() }
    }

    func cancelCrawl() {
        guard isRunning else { return }
        isRunning = false
        isPaused = false
        Task { await crawlerService.cancel() }
        crawlTask?.cancel()
        progressContinuation?.cancel()
        crawlTask = nil
        progressContinuation = nil
    }

    func updateExcludes(extensions: [String], folders: [String]) {
        excludeExtensions = extensions
        excludeFolders = folders
    }

    private var errorMessage: String?
}
