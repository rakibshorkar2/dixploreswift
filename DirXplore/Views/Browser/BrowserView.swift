import SwiftUI

@Observable
final class BrowserViewModel {
    var addressText = "http://172.16.50.4/"
    var currentURL: URL?
    var breadcrumbs: [URL] = []
    var items: [FileItem] = []
    var isLoading = false
    var isSearchActive = false
    var searchQuery = ""
    var searchSuggestions: [String] = []
    var sortOption: SortOption = .name
    var sortAscending = true
    var canGoBack = false
    var canGoForward = false

    enum SortOption: String, CaseIterable {
        case name, size, date
    }

    func loadDirectory(_ url: URL) async {}
    func refresh() async {}
    func goBack() {}
    func goForward() {}
    func navigateToBreadcrumb(_ url: URL) async {}
    func toggleFavorite(_ item: FileItem) {}
    func downloadItem(_ item: FileItem) {}
    func deleteItem(_ item: FileItem) {}
}

struct BrowserView: View {
    @Environment(BrowserViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics
    @State private var showSearch = false
    @State private var hasLoadedDefault = false

    var body: some View {
        @Bindable var vm = viewModel

        return VStack(spacing: 0) {
            addressBar
            breadcrumbsBar
            DirectoryListView()
                .refreshable { await viewModel.refresh() }
        }
        .navigationTitle("Browser")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .searchable(
            text: $vm.searchQuery,
            isPresented: $vm.isSearchActive,
            placement: .toolbar,
            prompt: "Search files…"
        )
        .sheet(isPresented: $showSearch) {
            SearchOverlayView()
        }
        .onAppear {
            if !hasLoadedDefault && viewModel.addressText == "http://172.16.50.4/" {
                hasLoadedDefault = true
                Task { await navigateToAddress() }
            }
        }
    }

    @ViewBuilder
    private var addressBar: some View {
        @Bindable var vm = viewModel

        HStack(spacing: 6) {
            Button { viewModel.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .disabled(!viewModel.canGoBack)

            Button { viewModel.goForward() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .disabled(!viewModel.canGoForward)

            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("Address or search…", text: $vm.addressText)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.webSearch)
                    .submitLabel(.go)
                    .onSubmit {
                        Task { await navigateToAddress() }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))

            Button { Task { await viewModel.refresh() } } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var breadcrumbsBar: some View {
        if !viewModel.breadcrumbs.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(Array(viewModel.breadcrumbs.enumerated()), id: \.offset) { index, url in
                        if index > 0 {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Button {
                            Task { await viewModel.navigateToBreadcrumb(url) }
                        } label: {
                            Text(url.lastPathComponent.isEmpty ? url.host ?? url.absoluteString : url.lastPathComponent)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(.secondary.opacity(0.2))
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .scrollClipDisabled()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Menu {
                Picker("Sort by", selection: $viewModel.sortOption) {
                    ForEach(BrowserViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
                Divider()
                Button {
                    withAnimation { viewModel.sortAscending.toggle() }
                } label: {
                    Label(
                        viewModel.sortAscending ? "Ascending" : "Descending",
                        systemImage: viewModel.sortAscending
                            ? "arrow.up" : "arrow.down"
                    )
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }

            Button {
                withAnimation { viewModel.isSearchActive.toggle() }
            } label: {
                Image(systemName: viewModel.isSearchActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }

            NavigationLink {
                CrawlerView()
            } label: {
                Image(systemName: "antenna.radiowaves.left.and.right")
            }
        }
    }

    private func navigateToAddress() async {
        let text = viewModel.addressText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        var urlString = text
        if !urlString.contains(".") {
            urlString = "https://www.google.com/search?q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text)"
        } else if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://\(urlString)"
        }
        guard let url = URL(string: urlString) else { return }
        await viewModel.loadDirectory(url)
    }
}

struct SearchOverlayView: View {
    @Environment(BrowserViewModel.self) private var viewModel
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        NavigationStack {
            List {
                if viewModel.searchSuggestions.isEmpty {
                    ContentUnavailableView(
                        "No Suggestions",
                        systemImage: "magnifyingglass",
                        description: Text("Type to search your browsing history.")
                    )
                } else {
                    ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                        Button {
                            viewModel.addressText = suggestion
                            dismissSearch()
                            Task { await viewModel.loadDirectory(URL(string: suggestion)!) }
                        } label: {
                            Label(suggestion, systemImage: "clock.arrow.circlepath")
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Search History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
