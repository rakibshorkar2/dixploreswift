import Foundation
import SwiftData

@Model
final class TorrentItem {
    @Attribute(.unique) var id: UUID
    var magnetUri: String?
    var torrentFileName: String?
    var name: String
    var status: String
    var totalBytes: Int64
    var downloadedBytes: Int64
    var uploadedBytes: Int64
    var downloadSpeed: Double
    var uploadSpeed: Double
    var seeders: Int
    var leechers: Int
    var progress: Double
    var sequentialMode: Bool
    var savePath: String

    convenience init(
        magnetUri: String,
        name: String,
        savePath: String
    ) {
        self.init()
        self.id = UUID()
        self.magnetUri = magnetUri
        self.name = name
        self.status = "downloading"
        self.totalBytes = 0
        self.downloadedBytes = 0
        self.uploadedBytes = 0
        self.downloadSpeed = 0
        self.uploadSpeed = 0
        self.seeders = 0
        self.leechers = 0
        self.progress = 0
        self.sequentialMode = false
        self.savePath = savePath
    }

    convenience init(
        torrentFileName: String,
        data: Data,
        name: String,
        savePath: String
    ) {
        self.init()
        self.id = UUID()
        self.torrentFileName = torrentFileName
        self.name = name
        self.status = "downloading"
        self.totalBytes = 0
        self.downloadedBytes = 0
        self.uploadedBytes = 0
        self.downloadSpeed = 0
        self.uploadSpeed = 0
        self.seeders = 0
        self.leechers = 0
        self.progress = 0
        self.sequentialMode = false
        self.savePath = savePath
    }
}
