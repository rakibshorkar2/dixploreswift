import SwiftUI

@Observable
final class CrawlerViewModel {
    var rootURL = ""
    var maxDepth = 3.0
    var excludeExtensions = ""
    var excludeFolders = ""
    var discoveredCount = 0
    var visitedCount = 0
    var estimatedRemaining = 0
    var progress: Double = 0
    var state: CrawlerState = .idle

    enum CrawlerState: String {
        case idle, running, paused, completed, failed
    }

    func start() {}
    func pause() {}
    func resume() {}
    func stop() {}
}

struct CrawlerView: View {
    @Environment(CrawlerViewModel.self) private var viewModel
    @Environment(HapticsManager.self) private var haptics

    var body: some View {
        @Bindable var vm = viewModel
        let isRunning = viewModel.state == .running || viewModel.state == .paused

        return NavigationStack {
            Form {
                targetSection
                settingsSection
                if viewModel.state == .running || viewModel.state == .paused || viewModel.state == .completed {
                    progressSection
                }
                controlsSection
            }
            .navigationTitle("Crawler")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(viewModel.state == .running && !isRunning)
        }
    }

    @ViewBuilder
    private var targetSection: some View {
        @Bindable var vm = viewModel

        Section("Target") {
            TextField("Root URL", text: $vm.rootURL)
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if viewModel.state != .idle {
                LabeledContent("Discovered") {
                    Text("\(viewModel.discoveredCount)")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Visited") {
                    Text("\(viewModel.visitedCount)")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var settingsSection: some View {
        @Bindable var vm = viewModel

        Section("Settings") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Max Depth: \(Int(viewModel.maxDepth))")
                    .font(.subheadline)
                Slider(value: $vm.maxDepth, in: 1...10, step: 1)
            }

            TextField("Exclude Extensions (comma separated)", text: $vm.excludeExtensions)
                .font(.subheadline)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            TextField("Exclude Folders (comma separated)", text: $vm.excludeFolders)
                .font(.subheadline)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        Section("Progress") {
            ProgressView(value: viewModel.progress)
                .tint(.accentColor)

            LabeledContent("Discovered") {
                Text("\(viewModel.discoveredCount)")
            }
            LabeledContent("Visited") {
                Text("\(viewModel.visitedCount)")
            }
            LabeledContent("Estimated remaining") {
                Text("\(viewModel.estimatedRemaining)")
            }
        }
    }

    @ViewBuilder
    private var controlsSection: some View {
        Section("Controls") {
            Button {
                haptics.medium()
                switch viewModel.state {
                case .idle, .completed: viewModel.start()
                case .running: viewModel.pause()
                case .paused: viewModel.resume()
                case .failed: viewModel.start()
                }
            } label: {
                HStack {
                    Spacer()
                    Label(
                        controlButtonLabel,
                        systemImage: controlButtonIcon
                    )
                    .font(.headline)
                    Spacer()
                }
            }
            .tint(controlButtonTint)
            .disabled(viewModel.state == .running)

            if viewModel.state == .running || viewModel.state == .paused {
                Button(role: .destructive) {
                    haptics.warning()
                    viewModel.stop()
                } label: {
                    HStack {
                        Spacer()
                        Label("Stop", systemImage: "stop.fill")
                            .font(.headline)
                        Spacer()
                    }
                }
            }
        }
    }

    private var controlButtonLabel: String {
        switch viewModel.state {
        case .idle: return "Start"
        case .running: return "Pause"
        case .paused: return "Resume"
        case .completed: return "Start New"
        case .failed: return "Retry"
        }
    }

    private var controlButtonIcon: String {
        switch viewModel.state {
        case .idle: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        case .completed: return "arrow.counterclockwise"
        case .failed: return "exclamationmark.arrow.circlepath"
        }
    }

    private var controlButtonTint: Color {
        switch viewModel.state {
        case .idle: return .accentColor
        case .running: return .orange
        case .paused: return .green
        case .completed: return .accentColor
        case .failed: return .red
        }
    }
}
