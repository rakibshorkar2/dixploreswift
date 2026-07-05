import Foundation
import Observation
import SwiftData
import SwiftSoup

@Observable
final class BrowserViewModel {
    var currentURL: URL?
    var items: [FileItem] = []
    var breadcrumbs: [(String, URL)] = []
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""
    var sortOrder: SortOrder = .name(.ascending)
    var history: [HistoryItem] = []

    enum SortOrder: Equatable {
        case name(SortDirection)
        case size(SortDirection)
        case date(SortDirection)

        enum SortDirection: String, Equatable { case ascending, descending }

        var field: String {
            switch self {
            case .name: return "name"
            case .size: return "size"
            case .date: return "date"
            }
        }

        var direction: SortDirection {
            switch self {
            case .name(let d), .size(let d), .date(let d): return d
            }
        }
    }

    private var navigationStack: [URL] = []
    private var currentIndex: Int = -1
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var canGoBack: Bool { currentIndex > 0 }
    var canGoForward: Bool { currentIndex < navigationStack.count - 1 }

    func navigateTo(url: URL) async {
        isLoading = true
        errorMessage = nil
        currentURL = url

        if currentIndex < navigationStack.count - 1 {
            navigationStack = Array(navigationStack.prefix(through: currentIndex))
        }
        navigationStack.append(url)
        currentIndex = navigationStack.count - 1
        buildBreadcrumbs(from: url)

        await fetchDirectory(url: url)
    }

    func navigateBack() {
        guard canGoBack else { return }
        currentIndex -= 1
        let url = navigationStack[currentIndex]
        currentURL = url
        buildBreadcrumbs(from: url)
        Task { await fetchDirectory(url: url) }
    }

    func navigateForward() {
        guard canGoForward else { return }
        currentIndex += 1
        let url = navigationStack[currentIndex]
        currentURL = url
        buildBreadcrumbs(from: url)
        Task { await fetchDirectory(url: url) }
    }

    func refresh() async {
        guard let url = currentURL else { return }
        await fetchDirectory(url: url)
    }

    func sort(by sortOrder: SortOrder) async {
        self.sortOrder = sortOrder
        sortItems()
    }

    func search(query: String) {
        searchQuery = query
    }

    var filteredItems: [FileItem] {
        if searchQuery.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    func addFavorite(item: FileItem) async {
        let favorite = FavoriteItem(name: item.name, url: item.url, type: item.isDirectory ? "folder" : "file")
        modelContext.insert(favorite)
        try? modelContext.save()
    }

    func addHistory(url: URL) async {
        let title = url.lastPathComponent.isEmpty ? url.absoluteString : url.lastPathComponent
        let item = HistoryItem(url: url, title: title)
        modelContext.insert(item)
        try? modelContext.save()
        loadHistory()
    }

    func loadHistory() {
        let descriptor = FetchDescriptor<HistoryItem>(sortBy: [SortDescriptor(\.visitDate, order: .reverse)])
        history = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchDirectory(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                errorMessage = "Unable to decode response"
                isLoading = false
                return
            }
            items = parseDirectoryListing(html: html, baseURL: url)
            sortItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func buildBreadcrumbs(from url: URL) {
        breadcrumbs.removeAll()
        let components = url.pathComponents.filter { $0 != "/" }
        var cumulative = ""
        for component in components {
            cumulative += "/" + component
            if let crumbURL = URL(string: cumulative, relativeTo: url.baseURL)?.absoluteURL {
                breadcrumbs.append((component, crumbURL))
            }
        }
    }

    private func sortItems() {
        switch sortOrder {
        case .name(let direction):
            items.sort { direction == .ascending ? $0.name.localizedStandardCompare($1.name) == .orderedAscending : $0.name.localizedStandardCompare($1.name) == .orderedDescending }
        case .size(let direction):
            items.sort { direction == .ascending ? ($0.size ?? 0) < ($1.size ?? 0) : ($0.size ?? 0) > ($1.size ?? 0) }
        case .date(let direction):
            items.sort { direction == .ascending ? ($0.modifiedDate ?? .distantPast) < ($1.modifiedDate ?? .distantPast) : ($0.modifiedDate ?? .distantPast) > ($1.modifiedDate ?? .distantPast) }
        }
    }

    func parseDirectoryListing(html: String, baseURL: URL) -> [FileItem] {
        guard let doc = try? SwiftSoup.parse(html) else { return [] }

        if let items = parseApacheTable(doc, baseURL: baseURL) {
            return items
        }

        if let items = parseNginxListing(doc, baseURL: baseURL) {
            return items
        }

        return parseGenericLinks(doc, baseURL: baseURL)
    }

    private func parseApacheTable(_ doc: Document, baseURL: URL) -> [FileItem]? {
        guard let table = try? doc.select("table").first() else { return nil }
        let rows = try? table.select("tr")
        guard let rows, rows.count > 1 else { return nil }

        var result: [FileItem] = []
        for row in rows.dropFirst() {
            let cols = try? row.select("td")
            guard let cols, cols.count >= 2 else { continue }

            let link = try? cols.get(1).select("a").first()
            guard let link, let href = try? link.attr("href") else { continue }
            let displayName = try? link.text()
            guard let displayName, !displayName.isEmpty else { continue }

            if displayName == "Parent Directory" || href == "../" { continue }

            let resolvedURL = URL(string: href, relativeTo: baseURL)?.absoluteURL ?? baseURL
            let isDir = href.hasSuffix("/")
            let ext = isDir ? nil : (displayName as NSString).pathExtension

            var size: Int64?
            var modifiedDate: Date?

            if cols.count >= 3 {
                let dateStr = try? cols.get(2).text()
                if let dateStr, !dateStr.isEmpty {
                    modifiedDate = parseApacheDate(dateStr)
                }
            }

            if cols.count >= 4 {
                let sizeStr = try? cols.get(3).text()
                if let sizeStr, sizeStr != "-" {
                    size = parseSize(sizeStr)
                }
            }

            let name = isDir ? String(displayName.dropLast()) : displayName
            result.append(FileItem(name: name, url: resolvedURL, isDirectory: isDir, size: size, modifiedDate: modifiedDate, extension: ext))
        }

        return result.isEmpty ? nil : result
    }

    private func parseNginxListing(_ doc: Document, baseURL: URL) -> [FileItem]? {
        guard let pre = try? doc.select("pre").first() else { return nil }
        let htmlContent = try? pre.html()
        guard let htmlContent else { return nil }

        let fragment = try? SwiftSoup.parseBodyFragment(htmlContent)
        guard let fragment else { return nil }
        let links = try? fragment.select("a")
        guard let links else { return nil }

        var result: [FileItem] = []
        for link in links {
            guard let href = try? link.attr("href") else { continue }
            let text = try? link.text()
            guard let text, !text.isEmpty else { continue }

            if text == "../" || href == "../" { continue }

            let resolvedURL = URL(string: href, relativeTo: baseURL)?.absoluteURL ?? baseURL
            let isDir = href.hasSuffix("/")
            let ext = isDir ? nil : (text as NSString).pathExtension

            let line = htmlContent.components(separatedBy: .newlines).first { $0.contains(href) }

            var modifiedDate: Date?
            var size: Int64?

            if let line {
                let stripped = line.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
                let parts = stripped.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

                let fmt = DateFormatter()
                fmt.dateFormat = "dd-MMM-yyyy HH:mm"
                fmt.locale = Locale(identifier: "en_US_POSIX")

                for (i, part) in parts.enumerated() {
                    guard let date = fmt.date(from: part) else { continue }
                    if i + 1 < parts.count {
                        let candidate = "\(part) \(parts[i + 1])"
                        if let full = fmt.date(from: candidate) {
                            modifiedDate = full
                        } else {
                            modifiedDate = date
                        }
                    } else {
                        modifiedDate = date
                    }
                    for j in (i + 2)..<parts.count {
                        if parts[j] != "-", let bytes = Int64(parts[j]) {
                            size = bytes
                        }
                        break
                    }
                    break
                }
            }

            result.append(FileItem(name: text, url: resolvedURL, isDirectory: isDir, size: size, modifiedDate: modifiedDate, extension: ext))
        }

        return result.isEmpty ? nil : result
    }

    private func parseGenericLinks(_ doc: Document, baseURL: URL) -> [FileItem] {
        guard let links = try? doc.select("a") else { return [] }

        var result: [FileItem] = []
        for link in links {
            guard let href = try? link.attr("href") else { continue }
            let text = try? link.text()
            guard let text, !text.isEmpty else { continue }

            if href.hasPrefix("#") || href.hasPrefix("javascript:") || href.hasPrefix("mailto:") { continue }
            if text == "Parent Directory" || href == "../" { continue }

            let resolvedURL = URL(string: href, relativeTo: baseURL)?.absoluteURL ?? baseURL
            let isDir = href.hasSuffix("/")
            let ext = isDir ? nil : (text as NSString).pathExtension

            result.append(FileItem(name: text, url: resolvedURL, isDirectory: isDir, extension: ext))
        }

        return result
    }

    private func parseApacheDate(_ dateStr: String) -> Date? {
        let patterns = ["yyyy-MM-dd HH:mm", "yyyy-MM-dd HH:mm:ss", "dd-MMM-yyyy HH:mm", "yyyy-MM-dd"]
        let loc = Locale(identifier: "en_US_POSIX")
        for pattern in patterns {
            let fmt = DateFormatter()
            fmt.dateFormat = pattern
            fmt.locale = loc
            if let date = fmt.date(from: dateStr) {
                return date
            }
        }
        return nil
    }

    private func parseSize(_ sizeStr: String) -> Int64? {
        let trimmed = sizeStr.trimmingCharacters(in: .whitespaces)
        guard trimmed != "-" else { return nil }

        let unit = trimmed.suffix(1).lowercased()
        guard let numStr = Double(String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)) else {
            return Int64(trimmed)
        }

        switch unit {
        case "k": return Int64(numStr * 1024)
        case "m": return Int64(numStr * 1024 * 1024)
        case "g": return Int64(numStr * 1024 * 1024 * 1024)
        default: return Int64(trimmed)
        }
    }
}
