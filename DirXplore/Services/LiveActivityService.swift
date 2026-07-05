import ActivityKit
import WidgetKit
import SwiftUI
import OSLog

struct DownloadActivityAttributes: ActivityAttributes {
    public typealias DownloadState = ContentState

    public struct ContentState: Codable, Hashable {
        var downloadedBytes: Int
        var speed: Double
        var status: String
    }

    var downloadId: String
    var fileName: String
    var totalBytes: Int
}

struct TorrentActivityAttributes: ActivityAttributes {
    public typealias TorrentState = ContentState

    public struct ContentState: Codable, Hashable {
        var downloadedBytes: Int
        var speed: Double
        var status: String
        var seeders: Int
        var leechers: Int
    }

    var torrentId: String
    var torrentName: String
    var totalBytes: Int
}

@MainActor
final class LiveActivityService {
    private let logger = Logger(subsystem: "com.dirxplore", category: "LiveActivityService")

    func startDownloadActivity(downloadId: String, fileName: String, totalBytes: Int) async -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("ActivityKit is not available on this device")
            return nil
        }

        let attributes = DownloadActivityAttributes(
            downloadId: downloadId,
            fileName: fileName,
            totalBytes: totalBytes
        )

        let initialState = DownloadActivityAttributes.DownloadState(
            downloadedBytes: 0,
            speed: 0,
            status: "downloading"
        )

        do {
            let activity = try Activity<DownloadActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            logger.info("Started download Live Activity: \(activity.id)")
            return activity.id
        } catch {
            logger.error("Failed to start download Live Activity: \(error.localizedDescription)")
            return nil
        }
    }

    func updateDownloadActivity(activityId: String, downloadedBytes: Int, speed: Double, status: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let updatedState = DownloadActivityAttributes.DownloadState(
            downloadedBytes: downloadedBytes,
            speed: speed,
            status: status
        )

        let pushDescriptor = Activity<DownloadActivityAttributes>.ContentState(
            downloadedBytes: updatedState.downloadedBytes,
            speed: updatedState.speed,
            status: updatedState.status
        )

        for activity in Activity<DownloadActivityAttributes>.activities {
            guard activity.id == activityId else { continue }
            await activity.update(
                using: pushDescriptor
            )
            logger.info("Updated download Live Activity: \(activityId)")
            return
        }
    }

    func endDownloadActivity(activityId: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        for activity in Activity<DownloadActivityAttributes>.activities {
            guard activity.id == activityId else { continue }
            let finalState = DownloadActivityAttributes.DownloadState(
                downloadedBytes: 0,
                speed: 0,
                status: "completed"
            )
            await activity.end(
                using: finalState,
                dismissalPolicy: .immediate
            )
            logger.info("Ended download Live Activity: \(activityId)")
            return
        }
    }

    func startTorrentActivity(torrentId: String, torrentName: String, totalBytes: Int) async -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("ActivityKit is not available on this device")
            return nil
        }

        let attributes = TorrentActivityAttributes(
            torrentId: torrentId,
            torrentName: torrentName,
            totalBytes: totalBytes
        )

        let initialState = TorrentActivityAttributes.TorrentState(
            downloadedBytes: 0,
            speed: 0,
            status: "downloading",
            seeders: 0,
            leechers: 0
        )

        do {
            let activity = try Activity<TorrentActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
            logger.info("Started torrent Live Activity: \(activity.id)")
            return activity.id
        } catch {
            logger.error("Failed to start torrent Live Activity: \(error.localizedDescription)")
            return nil
        }
    }

    func updateTorrentActivity(activityId: String, downloadedBytes: Int, speed: Double, status: String, seeders: Int, leechers: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let updatedState = TorrentActivityAttributes.TorrentState(
            downloadedBytes: downloadedBytes,
            speed: speed,
            status: status,
            seeders: seeders,
            leechers: leechers
        )

        for activity in Activity<TorrentActivityAttributes>.activities {
            guard activity.id == activityId else { continue }
            await activity.update(
                using: updatedState
            )
            logger.info("Updated torrent Live Activity: \(activityId)")
            return
        }
    }

    func endTorrentActivity(activityId: String) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        for activity in Activity<TorrentActivityAttributes>.activities {
            guard activity.id == activityId else { continue }
            let finalState = TorrentActivityAttributes.TorrentState(
                downloadedBytes: 0,
                speed: 0,
                status: "completed",
                seeders: 0,
                leechers: 0
            )
            await activity.end(
                using: finalState,
                dismissalPolicy: .immediate
            )
            logger.info("Ended torrent Live Activity: \(activityId)")
            return
        }
    }
}
