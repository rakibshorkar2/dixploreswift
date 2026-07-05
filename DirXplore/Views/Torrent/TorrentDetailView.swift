import SwiftUI

struct TorrentDetailView: View {
    let item: TorrentItem
    @Environment(TorrentViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics

    private var progress: Double {
        min(max(item.progress, 0), 1)
    }

    private var progressPercent: Int {
        Int(progress * 100)
    }

    private var ratio: Double {
        guard item.downloadedBytes > 0 else { return 0 }
        return Double(item.uploadedBytes) / Double(item.downloadedBytes)
    }

    private let pieceGridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 20)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressSection
                statsGrid
                pieceProgressSection
                trackerSection
                settingsSection
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Torrent Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    @ViewBuilder
    private var progressSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(.tertiary.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [.accentColor, .accentColor.opacity(0.6)],
                            center: .center
                        ),
                        style: .init(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                VStack(spacing: 0) {
                    Text("\(progressPercent)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("%")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            Text(item.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(.top)
    }

    @ViewBuilder
    private var statsGrid: some View {
        GroupBox {
            Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    statCell("Downloaded", size: item.downloadedBytes)
                    statCell("Uploaded", size: item.uploadedBytes)
                }
                Divider()
                GridRow {
                    textStatCell("Ratio", String(format: "%.2f", ratio))
                    textStatCell("Availability", "—")
                }
                Divider()
                GridRow {
                    speedCell("DL", speed: item.downloadSpeed, color: .green)
                    speedCell("UL", speed: item.uploadSpeed, color: .orange)
                }
                Divider()
                GridRow {
                    textStatCell("Seeders", "\(item.seeders)")
                    textStatCell("Leechers", "\(item.leechers)")
                }
                Divider()
                GridRow {
                    textStatCell("Connections", "—")
                    textStatCell("Status", item.status.capitalized)
                }
            }
            .gridColumnAlignment(.leading)
        } label: {
            Label("Statistics", systemImage: "chart.bar.fill")
        }
    }

    private func statCell(_ label: String, size: Int64) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .binary))
                .font(.subheadline)
                .fontWeight(.medium)
                .minimumScaleFactor(0.7)
        }
    }

    private func textStatCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func speedCell(_ label: String, speed: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
            Text(ByteCountFormatter.string(fromByteCount: Int64(speed), countStyle: .binary) + "/s")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }

    @ViewBuilder
    private var pieceProgressSection: some View {
        GroupBox {
            let pieces = pieceProgressData()
            LazyVGrid(columns: pieceGridColumns, spacing: 2) {
                ForEach(Array(pieces.enumerated()), id: \.offset) { _, hasPiece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hasPiece ? Color.accentColor : Color.secondary.opacity(0.25))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        } label: {
            Label("Piece Progress", systemImage: "squareshape.split.2x2")
        }
    }

    private func pieceProgressData() -> [Bool] {
        let totalPieces = 200
        let completedPieces = Int(progress * Double(totalPieces))
        return (0..<totalPieces).map { $0 < completedPieces }
    }

    @ViewBuilder
    private var trackerSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                trackerRow("udp://tracker.opentrackr.org:1337", .green)
                trackerRow("udp://tracker.coppersurfer.tk:6969", .green)
                trackerRow("udp://tracker.leechers-paradise.org:6969", .secondary)
            }
        } label: {
            Label("Trackers (3)", systemImage: "point.3.connected.trianglepath.dotted")
        }
    }

    private func trackerRow(_ url: String, _ statusColor: Color) -> some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(url)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var settingsSection: some View {
        GroupBox {
            Toggle(isOn: .constant(item.sequentialMode)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sequential Download")
                        .font(.subheadline)
                    Text("Download pieces in order for sequential playback")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Download Speed Limit")
                    .font(.subheadline)
                HStack {
                    Text("Unlimited")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("10 MB/s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Slider(value: .constant(1), in: 0...1)
                    .tint(.accentColor)
            }
        } label: {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                haptics.medium()
                if item.status == "paused" {
                    viewModel.resumeTorrent(item)
                } else {
                    viewModel.pauseTorrent(item)
                }
            } label: {
                Label(
                    item.status == "paused" ? "Resume" : "Pause",
                    systemImage: item.status == "paused" ? "play.fill" : "pause.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(item.status == "paused" ? .green : .orange)

            Button(role: .destructive) {
                haptics.warning()
                viewModel.removeTorrent(item)
            } label: {
                Label("Remove", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }

        Button {
            haptics.medium()
            // Force recheck
        } label: {
            Label("Force Recheck", systemImage: "arrow.triangle.2.circlepath")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
