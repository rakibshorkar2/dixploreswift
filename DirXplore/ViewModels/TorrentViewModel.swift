import Foundation
import Observation
import SwiftData

@Observable
final class TorrentViewModel {
    var activeTorrents: [TorrentItem] = []
    var completedTorrents: [TorrentItem] = []
    var searchQuery = ""
    var searchResults: [TorrentSearchResult] = []
    var isSearching = false

    private let torrentService: TorrentService
    private let modelContext: ModelContext

    init(torrentService: TorrentService, modelContext: ModelContext) {
        self.torrentService = torrentService
        self.modelContext = modelContext
        loadTorrents()
    }

    func addMagnet(_ magnetURI: String) async {
        guard let url = URL(string: magnetURI) else { return }

        let name = extractTorrentName(from: magnetURI) ?? "Unknown"
        let savePath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        let item = TorrentItem(magnetUri: magnetURI, name: name, savePath: savePath)
        modelContext.insert(item)
        try? modelContext.save()
        await loadTorrents()
        await torrentService.startTorrent(id: item.id)
    }

    func addTorrentFile(url: URL) async {
        let savePath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        guard let data = try? Data(contentsOf: url) else { return }

        let fileName = url.lastPathComponent
        let name = url.deletingPathExtension().lastPathComponent
        let item = TorrentItem(torrentFileName: fileName, data: data, name: name, savePath: savePath)
        modelContext.insert(item)
        try? modelContext.save()
        await loadTorrents()
        await torrentService.startTorrent(id: item.id)
    }

    func startTorrent(id: UUID) async {
        await torrentService.startTorrent(id: id)
        await loadTorrents()
    }

    func pauseTorrent(id: UUID) async {
        await torrentService.pauseTorrent(id: id)
        if let item = activeTorrents.first(where: { $0.id == id }) {
            item.status = "paused"
            try? modelContext.save()
        }
        await loadTorrents()
    }

    func removeTorrent(id: UUID) async {
        await torrentService.removeTorrent(id: id)
        if let item = activeTorrents.first(where: { $0.id == id }) ?? completedTorrents.first(where: { $0.id == id }) {
            modelContext.delete(item)
            try? modelContext.save()
        }
        await loadTorrents()
    }

    func searchTorrents(query: String) async {
        guard !query.isEmpty else { return }
        isSearching = true
        searchQuery = query
        searchResults = []

        do {
            let results = try await searchPublicAPIs(query: query)
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        } catch {
            await MainActor.run { isSearching = false }
        }
    }

    func loadTorrents() {
        let descriptor = FetchDescriptor<TorrentItem>(sortBy: [SortDescriptor(\.name)])
        let all = (try? modelContext.fetch(descriptor)) ?? []
        activeTorrents = all.filter { $0.status == "downloading" || $0.status == "paused" || $0.status == "queued" }
        completedTorrents = all.filter { $0.status == "completed" || $0.status == "seeding" }
    }

    func setSequentialMode(id: UUID, enabled: Bool) async {
        if let item = activeTorrents.first(where: { $0.id == id }) {
            item.sequentialMode = enabled
            try? modelContext.save()
        }
        await torrentService.setSequentialMode(id: id, enabled: enabled)
    }

    private func extractTorrentName(from magnetURI: String) -> String? {
        guard let components = URLComponents(string: magnetURI) else { return nil }
        let dn = components.queryItems?.first(where: { $0.name == "dn" })?.value
        return dn?.removingPercentEncoding
    }

    private func searchPublicAPIs(query: String) async throws -> [TorrentSearchResult] {
        var allResults: [TorrentSearchResult] = []
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let sources: [(URL, String)] = [
            (URL(string: "https://apibay.org/q.php?q=\(encoded)")!, "APIBay"),
            (URL(string: "https://1337x.to/srch?search=\(encoded)")!, "1337x")
        ]

        for (url, source) in sources {
            guard let data = try? await URLSession.shared.data(from: url).0 else { continue }
            if let jsonResults = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
                for entry in jsonResults {
                    let name = entry["name"] ?? "Unknown"
                    let seeders = Int(entry["seeders"] ?? "0") ?? 0
                    let leechers = Int(entry["leechers"] ?? "0") ?? 0
                    let size = entry["size"] ?? "0"
                    let infoHash = entry["info_hash"] ?? ""
                    let magnetURI = "magnet:?xt=urn:btih:\(infoHash)&dn=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

                    allResults.append(TorrentSearchResult(
                        name: name,
                        seeders: seeders,
                        leechers: leechers,
                        size: formattedSize(bytes: Int64(size) ?? 0),
                        magnetURI: magnetURI,
                        source: source
                    ))
                }
            }
        }

        return allResults
    }

    private func formattedSize(bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct TorrentSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let seeders: Int
    let leechers: Int
    let size: String
    let magnetURI: String
    let source: String
}
