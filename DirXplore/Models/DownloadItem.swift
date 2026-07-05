import Foundation
import SwiftData

@Model
final class DownloadItem {
    @Attribute(.unique) var id: UUID
    var url: URL
    var fileName: String
    var filePath: String?
    var totalBytes: Int64
    var downloadedBytes: Int64
    var status: String
    var priority: Int
    var startDate: Date?
    var speed: Double
    var errorMessage: String?

    convenience init(
        url: URL,
        fileName: String,
        priority: Int = 1,
        totalBytes: Int64 = 0
    ) {
        self.init()
        self.id = UUID()
        self.url = url
        self.fileName = fileName
        self.totalBytes = totalBytes
        self.downloadedBytes = 0
        self.status = "downloading"
        self.priority = priority
        self.startDate = Date()
        self.speed = 0
    }
}
