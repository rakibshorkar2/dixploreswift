import SwiftUI
import AVKit
import AVFoundation

struct CustomMediaPlayerView: View {
    let videoURL: URL
    var autoPlay = true

    @State private var player = AVPlayer()
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var controlsTask: Task<Void, Never>?
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var playbackSpeed: Float = 1.0
    @State private var isLocked = false
    @State private var showSubtitlePicker = false
    @State private var showAudioPicker = false
    @State private var showSpeedPicker = false
    @State private var brightness: CGFloat = UIScreen.main.brightness
    @State private var volume: Float = AVAudioSession.sharedInstance().outputVolume
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    @State private var isMiniPlayer = false

    private let controlsAutoHideDelay: TimeInterval = 4

    private var timeObserver: Any?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VideoPlayerLayer(player: player)
                .scaleEffect(zoomScale)
                .gesture(magnificationGesture)
                .gesture(doubleTapGesture)
                .gesture(verticalSwipeGesture)
                .onTapGesture { toggleControls() }
                .ignoresSafeArea()

            if showControls && !isLocked {
                controlsOverlay
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
            }

            if isLocked {
                lockIndicator
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            controlsTask?.cancel()
            player.pause()
        }
        .statusBar(hidden: !showControls)
        .persistentSystemOverlays(showControls ? .visible : .hidden)
    }

    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        if autoPlay {
            player.play()
            isPlaying = true
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
            duration = player.currentItem?.duration.seconds ?? 0
        }

        startControlsAutoHide()
    }

    private func startControlsAutoHide() {
        controlsTask?.cancel()
        controlsTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(controlsAutoHideDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation { showControls = false }
        }
    }

    private func toggleControls() {
        withAnimation { showControls.toggle() }
        if showControls { startControlsAutoHide() }
    }

    private var controlsOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation { isLocked.toggle() }
                } label: {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .padding([.top, .trailing])
            }

            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    airPlayButton
                    PiPButton
                    subtitleButton
                    audioButton
                    speedButton
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

                Button {
                    togglePlayPause()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .symbolEffect(.scale, isActive: isPlaying)
                }

                HStack(spacing: 12) {
                    Text(timeFormatted(currentTime))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.8))

                    Slider(
                        value: $currentTime,
                        in: 0...max(duration, 1),
                        onEditingChanged: { editing in
                            if editing {
                                controlsTask?.cancel()
                            } else {
                                seek(to: currentTime)
                                startControlsAutoHide()
                            }
                        }
                    )
                    .tint(.white)

                    Text(timeFormatted(duration))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }

    private var lockIndicator: some View {
        VStack {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: .circle)
                .padding(.bottom, 40)
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        hapticsLight()
        startControlsAutoHide()
    }

    private func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    private func seekRelative(_ delta: Double) {
        let newTime = max(0, min(duration, currentTime + delta))
        seek(to: newTime)
        hapticsLight()
        startControlsAutoHide()
    }

    private var doubleTapGesture: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { location in
                let midX = UIScreen.main.bounds.width / 2
                if location.x < midX {
                    seekRelative(-10)
                } else {
                    seekRelative(10)
                }
            }
    }

    private var verticalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let translation = value.translation.height
                let startX = value.startLocation.x
                let midX = UIScreen.main.bounds.width / 2

                if startX < midX {
                    brightness = max(0, min(1, brightness - translation / 300))
                    UIScreen.main.brightness = brightness
                } else {
                    volume = max(0, min(1, volume - Float(translation / 300)))
                    if let view = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController?.view })
                        .first {
                        let slider = findVolumeSlider(in: view)
                        slider?.value = volume
                    }
                }
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                let newScale = lastZoomScale * scale
                zoomScale = max(1, min(3, newScale))
            }
            .onEnded { _ in
                lastZoomScale = zoomScale
            }
    }

    private var airPlayButton: some View {
        AirPlayView()
            .frame(width: 24, height: 24)
    }

    private var PiPButton: some View {
        Button {
            togglePiP()
        } label: {
            Image(systemName: "picture.in.picture")
        }
    }

    private var subtitleButton: some View {
        Button {
            showSubtitlePicker = true
            startControlsAutoHide()
        } label: {
            Image(systemName: "captions.bubble")
        }
        .confirmationDialog("Subtitle Track", isPresented: $showSubtitlePicker) {
            Button("None") {}
            Button("English") {}
            Button("Spanish") {}
            Button("Cancel", role: .cancel) {}
        }
    }

    private var audioButton: some View {
        Button {
            showAudioPicker = true
            startControlsAutoHide()
        } label: {
            Image(systemName: "speaker.wave.2")
        }
        .confirmationDialog("Audio Track", isPresented: $showAudioPicker) {
            Button("Original") {}
            Button("English") {}
            Button("Commentary") {}
            Button("Cancel", role: .cancel) {}
        }
    }

    private var speedButton: some View {
        Button {
            showSpeedPicker = true
            startControlsAutoHide()
        } label: {
            Text("\(playbackSpeed, specifier: "%.1fx")")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .confirmationDialog("Playback Speed", isPresented: $showSpeedPicker) {
            ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { speed in
                Button("\(speed, specifier: "%.1fx")") {
                    playbackSpeed = Float(speed)
                    player.rate = Float(speed)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func togglePiP() {
        guard let playerLayer = findPlayerLayer(),
              AVPictureInPictureController.isPictureInPictureSupported() else { return }
        if playerLayer.isPictureInPictureActive {
            playerLayer.stopPictureInPicture()
        } else {
            playerLayer.startPictureInPicture()
        }
    }

    private func findPlayerLayer() -> AVPictureInPictureController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return nil }
        return AVPictureInPictureController(contentViewController: AVPlayerViewController())
    }

    private func findVolumeSlider(in view: UIView) -> UISlider? {
        for subview in view.subviews {
            if let slider = subview as? UISlider, slider.accessibilityIdentifier == "volume" {
                return slider
            }
            if let found = findVolumeSlider(in: subview) { return found }
        }
        return nil
    }

    private func timeFormatted(_ totalSeconds: Double) -> String {
        guard totalSeconds.isFinite, !totalSeconds.isNaN else { return "0:00" }
        let total = Int(totalSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func hapticsLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct VideoPlayerLayer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

final class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

struct AirPlayView: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.tintColor = .white
        view.activeTintColor = .white
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
