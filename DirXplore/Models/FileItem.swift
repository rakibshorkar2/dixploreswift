import Foundation
import UniformTypeIdentifiers

struct FileItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let url: URL
    let isDirectory: Bool
    let size: Int64?
    let modifiedDate: Date?
    let `extension`: String?

    init(
        id: UUID = UUID(),
        name: String,
        url: URL,
        isDirectory: Bool,
        size: Int64? = nil,
        modifiedDate: Date? = nil,
        extension: String? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.isDirectory = isDirectory
        self.size = size
        self.modifiedDate = modifiedDate
        self.extension = `extension`
    }

    var formattedSize: String {
        guard let size else { return "—" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var iconName: String {
        if isDirectory { return "folder.fill" }
        guard let ext = `extension`?.lowercased() else { return "doc" }
        switch ext {
        case "mp4", "mov", "avi", "mkv", "webm": return "video.fill"
        case "mp3", "wav", "aac", "flac", "ogg": return "music.note"
        case "jpg", "jpeg", "png", "gif", "heic", "webp": return "photo.fill"
        case "pdf": return "doc.richtext.fill"
        case "zip", "rar", "7z", "tar", "gz": return "archivebox.fill"
        case "torrent": return "square.and.arrow.down.on.square.fill"
        case "txt", "md": return "doc.text.fill"
        case "json", "xml", "plist": return "gearshape.fill"
        default: return "doc.fill"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}
