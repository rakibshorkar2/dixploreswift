import SwiftUI
import SwiftData

@Observable
final class TorrentViewModel {
    var activeTorrents: [TorrentItem] = []
    var completedTorrents: [TorrentItem] = []
    var historyTorrents: [TorrentItem] = []
    var searchQuery = ""
    var searchResults: [TorrentSearchResult] = []
    var isSearching = false

    func pauseTorrent(_ item: TorrentItem) {}
    func resumeTorrent(_ item: TorrentItem) {}
    func removeTorrent(_ item: TorrentItem) {}
    func addMagnet(_ uri: String) async {}
    func importTorrentFile() {}
    func searchTorrents(_ query: String) async {}
}

struct TorrentSearchResult: Identifiable {
    let id: UUID
    let name: String
    let seeders: Int
    let leechers: Int
    let size: String
    let magnetURI: String

    init(name: String, seeders: Int, leechers: Int, size: String, magnetURI: String) {
        self.id = UUID()
        self.name = name
        self.seeders = seeders
        self.leechers = leechers
        self.size = size
        self.magnetURI = magnetURI
    }
}

struct TorrentHubView: View {
    @Environment(TorrentViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics
    @State private var showActionSheet = false
    @State private var showAddMagnetAlert = false
    @State private var magnetText = ""

    var body: some View {
        @Bindable var vm = viewModel

        return Group {
            if viewModel.activeTorrents.isEmpty && viewModel.completedTorrents.isEmpty && viewModel.historyTorrents.isEmpty {
                emptyState
            } else {
                List {
                    if !viewModel.activeTorrents.isEmpty {
                        Section("Active") {
                            ForEach(viewModel.activeTorrents) { item in
                                torrentRow(item)
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            viewModel.pauseTorrent(item)
                                        } label: {
                                            Label("Pause", systemImage: "pause.fill")
                                        }
                                        .tint(.orange)
                                        Button(role: .destructive) {
                                            viewModel.removeTorrent(item)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    if !viewModel.completedTorrents.isEmpty {
                        Section("Completed") {
                            ForEach(viewModel.completedTorrents) { item in
                                torrentRow(item)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.removeTorrent(item)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    if !viewModel.historyTorrents.isEmpty {
                        Section("History") {
                            ForEach(viewModel.historyTorrents) { item in
                                torrentRow(item)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Torrents")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showActionSheet = true
                } label: {
                    Image(systemName: "plus")
                }

                NavigationLink {
                    TorrentSearchView()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .confirmationDialog("Add Torrent", isPresented: $showActionSheet) {
            Button("Add Magnet Link") {
                showAddMagnetAlert = true
            }
            Button("Import Torrent File") {
                viewModel.importTorrentFile()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Add Magnet Link", isPresented: $showAddMagnetAlert) {
            TextField("magnet:?xt=urn:btih:…", text: $magnetText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Cancel", role: .cancel) {
                magnetText = ""
            }
            Button("Add") {
                Task { await viewModel.addMagnet(magnetText) }
                magnetText = ""
            }
        } message: {
            Text("Paste a magnet link to start downloading a torrent.")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Torrents",
            systemImage: "square.and.arrow.down.on.square",
            description: Text("Add a magnet link or import a .torrent file to get started.")
        )
    }

    private func torrentRow(_ item: TorrentItem) -> some View {
        NavigationLink {
            TorrentDetailView(item: item)
        } label: {
            VStack(spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.body)
                            .fontWeight(.semibold)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            statusBadge(item.status)
                            if item.seeders > 0 || item.leechers > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up")
                                        .font(.caption2)
                                    Text("\(item.seeders)")
                                }
                                .foregroundStyle(.green)
                                .font(.caption)

                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.down")
                                        .font(.caption2)
                                    Text("\(item.leechers)")
                                }
                                .foregroundStyle(.orange)
                                .font(.caption)
                            }
                        }
                    }

                    Spacer()

                    if item.downloadSpeed > 0 || item.uploadSpeed > 0 {
                        VStack(alignment: .trailing, spacing: 1) {
                            if item.downloadSpeed > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 8))
                                    Text(ByteCountFormatter.string(fromByteCount: Int64(item.downloadSpeed), countStyle: .binary) + "/s")
                                }
                                .foregroundStyle(.green)
                            }
                            if item.uploadSpeed > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 8))
                                    Text(ByteCountFormatter.string(fromByteCount: Int64(item.uploadSpeed), countStyle: .binary) + "/s")
                                }
                                .foregroundStyle(.orange)
                            }
                        }
                        .font(.caption2)
                    }
                }

                if item.status == "downloading" && item.progress < 1 {
                    ProgressView(value: item.progress)
                        .tint(.accentColor)
                }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func statusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "downloading": return .blue
            case "completed": return .green
            case "paused": return .orange
            case "seeding": return .purple
            case "failed": return .red
            default: return .secondary
            }
        }()

        Text(status.capitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(color.opacity(0.12), in: .capsule)
    }
}
