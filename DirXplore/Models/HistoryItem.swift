import Foundation
import SwiftData

@Model
final class HistoryItem {
    @Attribute(.unique) var id: UUID
    var url: URL
    var title: String?
    var visitDate: Date

    init(url: URL, title: String? = nil) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.visitDate = Date()
    }
}
