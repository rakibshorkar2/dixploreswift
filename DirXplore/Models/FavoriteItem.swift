import Foundation
import SwiftData

@Model
final class FavoriteItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: URL?
    var searchQuery: String?
    var torrentId: UUID?
    var type: String
    var dateAdded: Date

    init(
        name: String,
        url: URL? = nil,
        searchQuery: String? = nil,
        torrentId: UUID? = nil,
        type: String
    ) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.searchQuery = searchQuery
        self.torrentId = torrentId
        self.type = type
        self.dateAdded = Date()
    }
}
