import Foundation
import OSLog

private let logger = Logger(subsystem: "com.dirxplore", category: "Download")

actor DownloadService {
    struct DownloadTask {
        let id: UUID
        let url: URL
        let fileName: String
        let priority: Int
        var urlSessionTask: URLSessionDownloadTask?
        var progress: Double
        var speed: Double
        var continuation: AsyncStream<(UUID, Double, Double)>.Continuation?
    }

    private(set) var activeDownloads: [UUID: DownloadTask] = [:]
    private(set) var maxConcurrent: Int = 3

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.dirxplore.downloads")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    func startDownload(url: URL, fileName: String, priority: Int = 1) async -> UUID {
        let id = UUID()
        let task = DownloadTask(
            id: id,
            url: url,
            fileName: fileName,
            priority: priority,
            progress: 0,
            speed: 0
        )
        activeDownloads[id] = task

        let downloadTask = session.downloadTask(with: url)
        activeDownloads[id]?.urlSessionTask = downloadTask
        downloadTask.resume()

        logger.info("Download started: \(fileName) [\(id)]")
        return id
    }

    func pauseDownload(id: UUID) async {
        guard var task = activeDownloads[id] else { return }
        task.urlSessionTask?.cancel(byProducingResumeData: nil)
        activeDownloads[id] = task
        logger.info("Download paused: \(task.fileName) [\(id)]")
    }

    func resumeDownload(id: UUID) async {
        guard let task = activeDownloads[id] else { return }
        let downloadTask = session.downloadTask(with: task.url)
        activeDownloads[id]?.urlSessionTask = downloadTask
        downloadTask.resume()
        logger.info("Download resumed: \(task.fileName) [\(id)]")
    }

    func cancelDownload(id: UUID) async {
        guard let task = activeDownloads[id] else { return }
        task.urlSessionTask?.cancel()
        activeDownloads.removeValue(forKey: id)
        task.continuation?.finish()
        logger.info("Download cancelled: \(task.fileName) [\(id)]")
    }

    func downloadProgress() -> AsyncStream<(UUID, Double, Double)> {
        AsyncStream { continuation in

        }
    }

    func updateProgress(id: UUID, progress: Double, speed: Double) {
        guard var task = activeDownloads[id] else { return }
        task.progress = progress
        task.speed = speed
        activeDownloads[id] = task
        task.continuation?.yield((id, progress, speed))
    }

    func removeTask(id: UUID) {
        activeDownloads.removeValue(forKey: id)
    }
}
