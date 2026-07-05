import SwiftUI

struct DownloadDetailView: View {
    let item: DownloadItem
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false

    private var progress: Double {
        guard item.totalBytes > 0 else { return 0 }
        return Double(item.downloadedBytes) / Double(item.totalBytes)
    }

    private var progressPercent: Int {
        Int(progress * 100)
    }

    private var eta: String {
        guard item.speed > 0 else { return "—" }
        let remaining = item.totalBytes - item.downloadedBytes
        guard remaining > 0 else { return "—" }
        let seconds = Double(remaining) / item.speed
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: seconds) ?? "—"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressRing
                statsGrid
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Download Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showShare) {
            if let path = item.filePath {
                ShareSheet(items: [URL(fileURLWithPath: path)])
            }
        }
    }

    @ViewBuilder
    private var progressRing: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(.tertiary.opacity(0.2), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [.accentColor, .accentColor.opacity(0.6)],
                            center: .center
                        ),
                        style: .init(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                VStack(spacing: 2) {
                    Text("\(progressPercent)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("%")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 160, height: 160)

            Text(item.fileName)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    @ViewBuilder
    private var statsGrid: some View {
        GroupBox {
            Grid(horizontalSpacing: 16, verticalSpacing: 12) {
                GridRow {
                    statCell(label: "Speed", value: ByteCountFormatter.string(fromByteCount: Int64(item.speed), countStyle: .binary) + "/s")
                    statCell(label: "Downloaded", value: ByteCountFormatter.string(fromByteCount: item.downloadedBytes, countStyle: .file))
                }
                Divider()
                GridRow {
                    statCell(label: "Total Size", value: ByteCountFormatter.string(fromByteCount: item.totalBytes, countStyle: .file))
                    statCell(label: "ETA", value: eta)
                }
                Divider()
                GridRow {
                    statCell(label: "Status", value: item.status.capitalized)
                    statCell(label: "Avg Speed", value: "—")
                }
                Divider()
                GridRow {
                    statCell(label: "Peak Speed", value: "—")
                    statCell(label: "File Path", value: item.filePath ?? "—")
                }
            }
            .gridColumnAlignment(.leading)
        } label: {
            Label("Statistics", systemImage: "chart.bar.fill")
        }

        GroupBox {
            VStack(alignment: .leading, spacing: 4) {
                Text("Source URL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.url.absoluteString)
                    .font(.caption)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Source", systemImage: "link")
        }
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if item.status == "downloading" || item.status == "paused" {
            HStack(spacing: 16) {
                Button {
                    // Pause/Resume would use viewModel
                } label: {
                    Label(
                        item.status == "paused" ? "Resume" : "Pause",
                        systemImage: item.status == "paused" ? "play.fill" : "pause.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(role: .destructive) {
                    // Cancel
                } label: {
                    Label("Cancel", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }

        if item.status == "completed" {
            HStack(spacing: 16) {
                Button {
                    showShare = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    if let path = item.filePath {
                        let url = URL(fileURLWithPath: path)
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open", systemImage: "doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
