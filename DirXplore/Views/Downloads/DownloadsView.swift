import SwiftUI
import SwiftData

@Observable
final class DownloadManagerViewModel {
    var activeDownloads: [DownloadItem] = []
    var completedDownloads: [DownloadItem] = []
    var sortOption: SortOption = .date

    enum SortOption: String, CaseIterable {
        case date, size, speed
    }

    func pauseDownload(_ item: DownloadItem) {}
    func resumeDownload(_ item: DownloadItem) {}
    func cancelDownload(_ item: DownloadItem) {}
    func deleteDownload(_ item: DownloadItem) {}
    func clearCompleted() {}
}

struct DownloadsView: View {
    @Environment(DownloadManagerViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics
    @Environment(DownloadService.self) private var downloadService

    var body: some View {
        @Bindable var vm = viewModel

        return Group {
            if viewModel.activeDownloads.isEmpty && viewModel.completedDownloads.isEmpty {
                emptyState
            } else {
                List {
                    if !viewModel.activeDownloads.isEmpty {
                        Section("Active") {
                            ForEach(sorted(viewModel.activeDownloads)) { item in
                                DownloadRowView(item: item)
                                    .swipeActions(edge: .trailing) {
                                        if item.status == "downloading" {
                                            Button {
                                                viewModel.pauseDownload(item)
                                            } label: {
                                                Label("Pause", systemImage: "pause.fill")
                                            }
                                            .tint(.orange)
                                        } else if item.status == "paused" {
                                            Button {
                                                viewModel.resumeDownload(item)
                                            } label: {
                                                Label("Resume", systemImage: "play.fill")
                                            }
                                            .tint(.green)
                                        }
                                        Button(role: .destructive) {
                                            haptics.warning()
                                            viewModel.cancelDownload(item)
                                        } label: {
                                            Label("Cancel", systemImage: "xmark")
                                        }
                                    }
                            }
                        }
                    }

                    if !viewModel.completedDownloads.isEmpty {
                        Section("Completed") {
                            ForEach(sorted(viewModel.completedDownloads)) { item in
                                NavigationLink {
                                    DownloadDetailView(item: item)
                                } label: {
                                    DownloadRowView(item: item)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteDownload(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Downloads")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if !viewModel.completedDownloads.isEmpty {
                    Button {
                        withAnimation { viewModel.clearCompleted() }
                    } label: {
                        Image(systemName: "clear")
                    }
                }
                Menu {
                    Picker("Sort by", selection: $vm.sortOption) {
                        ForEach(DownloadManagerViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Downloads",
            systemImage: "arrow.down.circle",
            description: Text("Downloads will appear here when you start downloading files.")
        )
    }

    private func sorted(_ items: [DownloadItem]) -> [DownloadItem] {
        switch viewModel.sortOption {
        case .date:
            return items.sorted { ($0.startDate ?? .distantPast) > ($1.startDate ?? .distantPast) }
        case .size:
            return items.sorted { $0.totalBytes > $1.totalBytes }
        case .speed:
            return items.sorted { $0.speed > $1.speed }
        }
    }
}

struct DownloadRowView: View {
    let item: DownloadItem

    private var progress: Double {
        guard item.totalBytes > 0 else { return 0 }
        return Double(item.downloadedBytes) / Double(item.totalBytes)
    }

    private var formattedProgress: String {
        "\(Int(progress * 100))%"
    }

    private var statusColor: Color {
        switch item.status {
        case "downloading": return .blue
        case "paused": return .orange
        case "completed": return .green
        case "failed": return .red
        default: return .secondary
        }
    }

    private var statusLabel: String {
        switch item.status {
        case "downloading": return "Downloading"
        case "paused": return "Paused"
        case "completed": return "Completed"
        case "failed": return "Failed"
        default: return item.status
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fileName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(statusLabel)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(statusColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.12), in: .capsule)

                        if item.status == "downloading" || item.status == "paused" {
                            Text(formattedProgress)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                if item.status == "completed" {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }

            if item.status == "downloading" || item.status == "paused" {
                ProgressView(value: progress)
                    .tint(statusColor)

                HStack {
                    if item.speed > 0 {
                        Label(
                            ByteCountFormatter.string(fromByteCount: Int64(item.speed), countStyle: .binary) + "/s",
                            systemImage: "arrow.down"
                        )
                    }
                    Spacer()
                    if item.totalBytes > 0 {
                        Text("\(ByteCountFormatter.string(fromByteCount: item.downloadedBytes, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: item.totalBytes, countStyle: .file))")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
