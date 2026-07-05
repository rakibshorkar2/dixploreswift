import Foundation
import Observation
import SwiftData

@Observable
final class DownloadManagerViewModel {
    var downloads: [DownloadItem] = []
    var activeCount = 0
    var totalSpeed = 0.0
    var maxConcurrent = 3

    private let downloadService: DownloadService
    private let modelContext: ModelContext
    private var progressTask: Task<Void, Never>?

    init(downloadService: DownloadService, modelContext: ModelContext) {
        self.downloadService = downloadService
        self.modelContext = modelContext
        loadPreferences()
        loadDownloads()
        observeProgress()
    }

    private func loadPreferences() {
        let descriptor = FetchDescriptor<AppPreferences>()
        if let prefs = try? modelContext.fetch(descriptor).first {
            maxConcurrent = prefs.maxConcurrentDownloads
        }
    }

    func loadDownloads() {
        let descriptor = FetchDescriptor<DownloadItem>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        downloads = (try? modelContext.fetch(descriptor)) ?? []
        activeCount = downloads.filter { $0.status == "downloading" }.count
        totalSpeed = downloads.reduce(0) { $0 + $1.speed }
    }

    func startDownload(url: URL, fileName: String, priority: Int = 1) async {
        let id = await downloadService.startDownload(url: url, fileName: fileName, priority: priority)

        let item = DownloadItem(url: url, fileName: fileName, priority: priority)
        item.id = id
        modelContext.insert(item)
        try? modelContext.save()

        await MainActor.run { loadDownloads() }
    }

    func pauseDownload(id: UUID) async {
        await downloadService.pauseDownload(id: id)
        if let item = downloads.first(where: { $0.id == id }) {
            item.status = "paused"
            try? modelContext.save()
        }
        await MainActor.run { loadDownloads() }
    }

    func resumeDownload(id: UUID) async {
        await downloadService.resumeDownload(id: id)
        if let item = downloads.first(where: { $0.id == id }) {
            item.status = "downloading"
            try? modelContext.save()
        }
        await MainActor.run { loadDownloads() }
    }

    func cancelDownload(id: UUID) async {
        await downloadService.cancelDownload(id: id)
        if let item = downloads.first(where: { $0.id == id }) {
            item.status = "cancelled"
            try? modelContext.save()
        }
        await MainActor.run { loadDownloads() }
    }

    func removeDownload(id: UUID) async {
        await downloadService.cancelDownload(id: id)
        if let item = downloads.first(where: { $0.id == id }) {
            modelContext.delete(item)
            try? modelContext.save()
        }
        await MainActor.run { loadDownloads() }
    }

    func retryDownload(id: UUID) async {
        guard let existing = downloads.first(where: { $0.id == id }) else { return }
        let url = existing.url
        let fileName = existing.fileName
        let priority = existing.priority

        modelContext.delete(existing)
        try? modelContext.save()

        await startDownload(url: url, fileName: fileName, priority: priority)
    }

    func setPriority(id: UUID, priority: Int) async {
        if let item = downloads.first(where: { $0.id == id }) {
            item.priority = priority
            try? modelContext.save()
        }
        await MainActor.run { loadDownloads() }
    }

    func observeProgress() {
        progressTask = Task { [weak self] in
            guard let self else { return }

            for await (id, progress, speed) in downloadService.downloadProgress() {
                await MainActor.run {
                    if let item = self.downloads.first(where: { $0.id == id }) {
                        item.downloadedBytes = Int64(progress * Double(max(item.totalBytes, 1)))
                        item.speed = speed
                        if progress >= 1.0 {
                            item.status = "completed"
                        }
                        self.totalSpeed = self.downloads.reduce(0) { $0 + $1.speed }
                    }
                }
            }
        }
    }

    deinit {
        progressTask?.cancel()
    }
}
