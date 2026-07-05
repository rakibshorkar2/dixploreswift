import Foundation
import OSLog

private let logger = Logger(subsystem: "com.dirxplore", category: "Crawler")

actor CrawlerService {
    private(set) var isRunning = false
    private(set) var visitedCount = 0
    private(set) var remainingEstimate = 0
    private(set) var currentDepth = 0

    private var paused = false
    private var cancellationRequested = false
    private var discovered = Set<URL>()
    private var continuation: AsyncStream<(visited: Int, remaining: Int, depth: Int)>.Continuation?

    nonisolated var progressStream: AsyncStream<(visited: Int, remaining: Int, depth: Int)> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    func startCrawl(
        rootURL: URL,
        maxDepth: Int = 3,
        excludeExtensions: [String] = [],
        excludeFolders: [String] = []
    ) async {
        guard !isRunning else { return }
        isRunning = true
        paused = false
        cancellationRequested = false
        discovered.removeAll()
        visitedCount = 0
        remainingEstimate = 0
        currentDepth = 0

        let lowerExcludedExts = excludeExtensions.map { $0.lowercased() }
        let lowerExcludedDirs = excludeFolders.map { $0.lowercased() }

        await crawlBFS(
            root: rootURL,
            maxDepth: maxDepth,
            excludeExtensions: lowerExcludedExts,
            excludeFolders: lowerExcludedDirs
        )

        isRunning = false
        continuation?.finish()
    }

    private func crawlBFS(
        root: URL,
        maxDepth: Int,
        excludeExtensions: [String],
        excludeFolders: [String]
    ) async {
        struct WorkItem {
            let url: URL
            let depth: Int
        }

        var queue = [WorkItem(url: root, depth: 0)]
        var visited = Set<URL>()

        while !queue.isEmpty {
            if cancellationRequested { return }
            while paused && !cancellationRequested {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            let batch = queue
            queue.removeAll()

            await withTaskGroup(of: [WorkItem].self) { group in
                for item in batch {
                    group.addTask { [self] in
                        var newItems: [WorkItem] = []
                        guard !self.cancellationRequested else { return newItems }

                        do {
                            let (data, _) = try await URLSession.shared.data(from: item.url)
                            guard let html = String(data: data, encoding: .utf8) else {
                                return newItems
                            }
                            await self.recordVisited(url: item.url, depth: item.depth)

                            guard item.depth < maxDepth else { return newItems }

                            let links = self.parseLinks(from: html, base: item.url)
                            for link in links {
                                guard !visited.contains(link) else { continue }
                                visited.insert(link)

                                let lastComp = link.lastPathComponent.lowercased()
                                if excludeExtensions.contains(where: { lastComp.hasSuffix(".\($0)") }) { continue }
                                if excludeFolders.contains(where: { link.path.lowercased().contains("/\($0)/") }) { continue }

                                if self.looksLikeDirectory(link: link) {
                                    newItems.append(WorkItem(url: link, depth: item.depth + 1))
                                }
                            }
                        } catch {
                            logger.warning("Failed to fetch \(item.url): \(error.localizedDescription)")
                        }
                        return newItems
                    }
                }

                for await result in group {
                    queue.append(contentsOf: result)
                }
            }

            remainingEstimate = queue.count
            continuation?.yield((visitedCount, remainingEstimate, currentDepth))
        }
    }

    private func recordVisited(url: URL, depth: Int) {
        visitedCount += 1
        currentDepth = depth
        discovered.insert(url)
    }

    func pause() {
        paused = true
    }

    func resume() {
        paused = false
    }

    func cancel() {
        cancellationRequested = true
    }

    func discoveredURLs() -> [URL] {
        Array(discovered)
    }

    private func parseLinks(from html: String, base: URL) -> [URL] {
        var links: [URL] = []
        let patterns = [
            #"href\s*=\s*"([^"]+)""#,
            #"href\s*=\s*'([^']+)'"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }
            let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
            for match in matches {
                guard let range = Range(match.range(at: 1), in: html) else { continue }
                let href = String(html[range])
                if href.hasPrefix("#") || href.hasPrefix("javascript:") || href.hasPrefix("mailto:") { continue }
                if let resolved = URL(string: href, relativeTo: base)?.absoluteURL {
                    links.append(resolved)
                }
            }
        }
        return links
    }

    private func looksLikeDirectory(link: URL) -> Bool {
        let s = link.absoluteString
        return s.hasSuffix("/") || link.pathExtension.isEmpty
    }
}
