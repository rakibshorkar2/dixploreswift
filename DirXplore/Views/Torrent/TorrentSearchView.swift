import SwiftUI

struct TorrentSearchView: View {
    @Environment(TorrentViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics
    @State private var showMagnetAction = false
    @State private var selectedResult: TorrentSearchResult?

    var body: some View {
        @Bindable var vm = viewModel

        return Group {
            if viewModel.isSearching {
                Spacer()
                ProgressView("Searching…")
                    .controlSize(.large)
                Spacer()
            } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            } else if viewModel.searchQuery.isEmpty {
                ContentUnavailableView(
                    "Search for Torrents",
                    systemImage: "magnifyingglass",
                    description: Text("Find torrents from major indexes.")
                )
            } else {
                List {
                    ForEach(viewModel.searchResults) { result in
                        Button {
                            selectedResult = result
                            showMagnetAction = true
                        } label: {
                            TorrentSearchResultRow(result: result)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search Torrents")
        .searchable(
            text: $vm.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search torrents…"
        )
        .onSubmit(of: .search) {
            Task { await viewModel.searchTorrents(viewModel.searchQuery) }
        }
        .confirmationDialog(
            "Download Torrent",
            isPresented: $showMagnetAction,
            titleVisibility: .visible,
            presenting: selectedResult
        ) { result in
            Button("Download Magnet") {
                haptics.medium()
                Task { await viewModel.addMagnet(result.magnetURI) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { result in
            Text(result.name)
        }
    }
}

struct TorrentSearchResultRow: View {
    let result: TorrentSearchResult

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(result.seeders)", systemImage: "arrow.up")
                        .foregroundStyle(.green)
                    Label("\(result.leechers)", systemImage: "arrow.down")
                        .foregroundStyle(.orange)
                    Text(result.size)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }

            Spacer()

            Image(systemName: "chevron.down.circle")
                .font(.title3)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}
