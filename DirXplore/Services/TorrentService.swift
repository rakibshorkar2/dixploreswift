import Foundation
import OSLog

private let logger = Logger(subsystem: "com.dirxplore", category: "Torrent")

actor TorrentService {
    struct TorrentStatus {
        let id: UUID
        let progress: Double
        let downloadSpeed: Double
        let uploadSpeed: Double
        let seeders: Int
        let leechers: Int
        let totalPieces: Int
        let downloadedPieces: Int
        let state: String
    }

    private var activeTorrents: [UUID: TorrentStatus] = [:]
    private var torrentTimers: [UUID: Task<Void, Never>] = [:]

    func addMagnet(_ magnetURI: String) async -> UUID {
        let id = UUID()
        let status = TorrentStatus(
            id: id,
            progress: 0,
            downloadSpeed: 0,
            uploadSpeed: 0,
            seeders: 0,
            leechers: 0,
            totalPieces: 1,
            downloadedPieces: 0,
            state: "downloading"
        )
        activeTorrents[id] = status
        simulateProgress(id: id)
        logger.info("Magnet added: \(magnetURI.prefix(60))... [\(id)]")
        return id
    }

    func addTorrentFile(data: Data) async -> UUID {
        let id = UUID()
        let status = TorrentStatus(
            id: id,
            progress: 0,
            downloadSpeed: 0,
            uploadSpeed: 0,
            seeders: 0,
            leechers: 0,
            totalPieces: 1,
            downloadedPieces: 0,
            state: "downloading"
        )
        activeTorrents[id] = status
        simulateProgress(id: id)
        logger.info("Torrent file added [\(id)] (\(data.count) bytes)")
        return id
    }

    func startTorrent(id: UUID) async {
        guard var status = activeTorrents[id] else { return }
        status = TorrentStatus(
            id: id,
            progress: status.progress,
            downloadSpeed: status.downloadSpeed,
            uploadSpeed: status.uploadSpeed,
            seeders: status.seeders,
            leechers: status.leechers,
            totalPieces: status.totalPieces,
            downloadedPieces: status.downloadedPieces,
            state: "downloading"
        )
        activeTorrents[id] = status
        simulateProgress(id: id)
        logger.info("Torrent started [\(id)]")
    }

    func pauseTorrent(id: UUID) async {
        guard var status = activeTorrents[id] else { return }
        torrentTimers[id]?.cancel()
        torrentTimers.removeValue(forKey: id)
        status = TorrentStatus(
            id: id,
            progress: status.progress,
            downloadSpeed: 0,
            uploadSpeed: 0,
            seeders: status.seeders,
            leechers: status.leechers,
            totalPieces: status.totalPieces,
            downloadedPieces: status.downloadedPieces,
            state: "paused"
        )
        activeTorrents[id] = status
        logger.info("Torrent paused [\(id)]")
    }

    func removeTorrent(id: UUID) async {
        torrentTimers[id]?.cancel()
        torrentTimers.removeValue(forKey: id)
        activeTorrents.removeValue(forKey: id)
        logger.info("Torrent removed [\(id)]")
    }

    func getTorrentInfo(id: UUID) async -> TorrentStatus? {
        activeTorrents[id]
    }

    func setSequentialMode(id: UUID, enabled: Bool) async {
        logger.info("Sequential mode set to \(enabled) for [\(id)]")
    }

    private func simulateProgress(id: UUID) {
        let task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard let self = await self else { break }
                await self.tickProgress(id: id)
            }
        }
        torrentTimers[id] = task
    }

    private func tickProgress(id: UUID) {
        guard var status = activeTorrents[id], status.state != "paused" else { return }
        let increment = Double.random(in: 0.5...3.0)
        let newProgress = min(status.progress + increment, 100)
        let state = newProgress >= 100 ? "seeding" : "downloading"
        let dSpeed = Double.random(in: 500_000...5_000_000)
        let uSpeed = Double.random(in: 50_000...500_000)
        let newDownloaded = Int(Double(status.totalPieces) * newProgress / 100)

        status = TorrentStatus(
            id: id,
            progress: newProgress,
            downloadSpeed: dSpeed,
            uploadSpeed: uSpeed,
            seeders: Int.random(in: 1...50),
            leechers: Int.random(in: 0...10),
            totalPieces: status.totalPieces,
            downloadedPieces: newDownloaded,
            state: state
        )
        activeTorrents[id] = status

        if newProgress >= 100 {
            torrentTimers[id]?.cancel()
            torrentTimers.removeValue(forKey: id)
        }
    }
}
