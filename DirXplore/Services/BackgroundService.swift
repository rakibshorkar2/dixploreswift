import AVFoundation
import CoreLocation
import UIKit
import OSLog

@MainActor
final class BackgroundService: NSObject {
    private let logger = Logger(subsystem: "com.dirxplore", category: "BackgroundService")

    @Published private(set) var isKeepingAlive = false

    private var audioPlayer: AVAudioPlayer?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestPermissions() {
        locationManager.requestAlwaysAuthorization()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func startBackgroundTask() {
        guard !isKeepingAlive else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            logger.error("Failed to activate audio session: \(error.localizedDescription)")
        }

        if let audioData = generateSilenceAudioData() {
            do {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("silence_\(UUID().uuidString).wav")
                try audioData.write(to: tempURL)
                audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0.01
                audioPlayer?.play()
            } catch {
                logger.error("Failed to start audio player: \(error.localizedDescription)")
            }
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startMonitoringSignificantLocationChanges()

        isKeepingAlive = true
        logger.info("Background task started")
    }

    func stopBackgroundTask() {
        audioPlayer?.stop()
        audioPlayer = nil

        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = false

        isKeepingAlive = false
        logger.info("Background task stopped")
    }

    private func generateSilenceAudioData() -> Data? {
        let sampleRate: Double = 8000
        let duration: Double = 0.1
        let numFrames = Int(sampleRate * duration)
        let channels: UInt32 = 1
        let bitsPerChannel: UInt32 = 16

        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: false
        ) else { return nil }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numFrames))
        else { return nil }
        buffer.frameLength = buffer.frameCapacity

        if let channelData = buffer.int16ChannelData {
            channelData.pointee.initialize(repeating: 0, count: numFrames)
        }

        let headerSize = 44
        let dataSize = numFrames * Int(bitsPerChannel / 8) * Int(channels)
        var data = Data(capacity: headerSize + dataSize)

        func writeString(_ string: String) {
            data.append(string.data(using: .ascii)!)
        }
        func writeInt16(_ value: Int16) {
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
        }
        func writeInt32(_ value: Int32) {
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
        }

        writeString("RIFF")
        writeInt32(Int32(36 + dataSize))
        writeString("WAVE")
        writeString("fmt ")
        writeInt32(16)
        writeInt16(1)
        writeInt16(Int16(channels))
        writeInt32(Int32(sampleRate))
        writeInt32(Int32(sampleRate * Double(channels) * Double(bitsPerChannel / 8)))
        writeInt16(Int16(channels * bitsPerChannel / 8))
        writeInt16(Int16(bitsPerChannel))
        writeString("data")
        writeInt32(Int32(dataSize))

        if let channelData = buffer.int16ChannelData {
            let samples = UnsafeBufferPointer(start: channelData.pointee, count: numFrames)
            for sample in samples {
                writeInt16(sample)
            }
        }

        return data
    }
}

extension BackgroundService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.debug("Background location update received")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            logger.info("Location authorization granted")
        case .denied, .restricted:
            logger.warning("Location authorization denied")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
