import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteItem.dateAdded, order: .reverse) private var favorites: [FavoriteItem]
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false

    private var directories: [FavoriteItem] {
        favorites.filter { $0.type == "directory" }
    }

    private var torrents: [FavoriteItem] {
        favorites.filter { $0.type == "torrent" }
    }

    private var searches: [FavoriteItem] {
        favorites.filter { $0.type == "search" }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyState
                } else {
                    List {
                        if !directories.isEmpty {
                            Section("Directories") {
                                ForEach(directories) { item in
                                    FavoriteRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteFavorite(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        deleteFavorite(directories[index])
                                    }
                                }
                            }
                        }

                        if !torrents.isEmpty {
                            Section("Torrents") {
                                ForEach(torrents) { item in
                                    FavoriteRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteFavorite(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        deleteFavorite(torrents[index])
                                    }
                                }
                            }
                        }

                        if !searches.isEmpty {
                            Section("Searches") {
                                ForEach(searches) { item in
                                    FavoriteRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteFavorite(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        deleteFavorite(searches[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !favorites.isEmpty {
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Favorites Yet",
            systemImage: "star.slash",
            description: Text("Swipe to favorite items.")
        )
    }

    private func deleteFavorite(_ item: FavoriteItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

private struct FavoriteRow: View {
    let item: FavoriteItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .lineLimit(1)

                if let query = item.searchQuery {
                    Text(query)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if let url = item.url {
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(item.dateAdded.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var icon: String {
        switch item.type {
        case "directory": "folder.fill"
        case "torrent": "magnet.fill"
        case "search": "magnifyingglass"
        default: "star.fill"
        }
    }

    private var iconColor: Color {
        switch item.type {
        case "directory": .blue
        case "torrent": .orange
        case "search": .purple
        default: .yellow
        }
    }
}
