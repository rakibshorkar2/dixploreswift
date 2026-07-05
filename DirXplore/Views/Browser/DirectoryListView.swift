import SwiftUI

struct DirectoryListView: View {
    @Environment(BrowserViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics

    var body: some View {
        @Bindable var vm = viewModel

        let filtered = filteredItems

        return Group {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading…")
                    .controlSize(.large)
                Spacer()
            } else if filtered.isEmpty {
                ContentUnavailableView(
                    "No Files",
                    systemImage: "folder",
                    description: Text(viewModel.searchQuery.isEmpty ? "This directory is empty." : "No results for \"\(viewModel.searchQuery)\".")
                )
            } else {
                List {
                    ForEach(filtered) { item in
                        FileRowView(item: item)
                            .swipeActions(edge: .leading) {
                                Button {
                                    haptics.light()
                                    viewModel.toggleFavorite(item)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    haptics.warning()
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    shareItem(item)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                                Button {
                                    haptics.medium()
                                    viewModel.downloadItem(item)
                                } label: {
                                    Label("Download", systemImage: "arrow.down")
                                }
                                .tint(.green)
                            }
                            .contextMenu {
                                Button { viewModel.downloadItem(item) } label: {
                                    Label("Download", systemImage: "arrow.down")
                                }
                                Button { viewModel.toggleFavorite(item) } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                Button { copyURL(item) } label: {
                                    Label("Copy URL", systemImage: "doc.on.doc")
                                }
                                Button { shareItem(item) } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Button {
                                    UIApplication.shared.open(item.url)
                                } label: {
                                    Label("Open in Safari", systemImage: "safari")
                                }
                                Divider()
                                Button(role: .destructive) {
                                    haptics.warning()
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: filtered)
            }
        }
    }

    private var filteredItems: [FileItem] {
        let items = viewModel.items
        guard !viewModel.searchQuery.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(viewModel.searchQuery) }
    }

    private func shareItem(_ item: FileItem) {
        let av = UIActivityViewController(activityItems: [item.url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    private func copyURL(_ item: FileItem) {
        UIPasteboard.general.url = item.url
    }
}

struct FileRowView: View {
    let item: FileItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.title3)
                .foregroundStyle(item.isDirectory ? .blue : .secondary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let size = item.size {
                        Text(item.formattedSize)
                    }
                    if let date = item.modifiedDate {
                        Text(date, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if item.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .contentShape(.rect)
    }
}
