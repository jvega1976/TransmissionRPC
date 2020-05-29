//
//  RPCConfigValues.swift
//  TransmissionRPC
//
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//
//  RPC config values using in JSON requests/answers
//
import Foundation

public typealias JSONKey = String
public typealias JSONObject = [JSONKey: Any]


// MARK: - Torrent status values
@objc public enum TorrentStatus: Int, Codable {
    case stopped = 0 /* Torrent is stopped */
    case checkWait = 1 /* Queued to check files */
    case check = 2 /* Checking files */
    case downloadWait = 3 /* Queued to download */
    case download = 4 /* Downloading */
    case seedWait = 5 /* Queued to seed */
    case seed = 6 /* Seeding */
    case unknown = 7
    
    public var statusString: String {
        switch self {
            case .download:
                return NSLocalizedString("trDownloading", comment: "")
            case .downloadWait:
                return NSLocalizedString("trWaiting", comment: "")
            case .check:
                return NSLocalizedString("trWaitingCheck", comment: "")
            case .checkWait:
                return NSLocalizedString("trWaitingCheck", comment: "")
            case .seedWait:
                return NSLocalizedString("trWaitingSeed", comment: "")
            case .seed:
                return NSLocalizedString("trSeeding", comment: "")
            case .stopped:
                return NSLocalizedString("trStopped", comment: "")
            case .unknown:
                return NSLocalizedString("unknown", comment: "")
        }
    }
}

// MARK: - RPC JSON Message Keys
public struct JSONKeys: Codable, Hashable {
    public static let delete_local_data: JSONKey = "delete-local-data"
    public static let fields: JSONKey = "fields"
    public static let activityDate: JSONKey = "activityDate"
    public static let editDate: JSONKey = "editDate"
    public static let addedDate: JSONKey = "addedDate"
    public static let bandwidthPriority: JSONKey = "bandwidthPriority"
    public static let comment: JSONKey = "comment"
    public static let creator: JSONKey = "creator"
    public static let dateCreated: JSONKey = "dateCreated"
    public static let doneDate: JSONKey = "doneDate"
    public static let downloadDir: JSONKey = "downloadDir"
    public static let downloadedEver: JSONKey = "downloadedEver"
    public static let downloadLimit: JSONKey = "downloadLimit"
    public static let downloadLimited: JSONKey = "downloadLimited"
    public static let error: JSONKey = "error"
    public static let errorString: JSONKey = "errorString"
    public static let eta: JSONKey = "eta"
    public static let bytesCompleted: JSONKey = "bytesCompleted"
    public static let length: JSONKey = "length"
    public static let name: JSONKey = "name"
    public static let pathComponents: JSONKey = "pathComponents"
    public static let priority: JSONKey = "priority"
    public static let wanted: JSONKey = "wanted"
    public static let files: JSONKey = "files"
    public static let priority_high: JSONKey = "priority-high"
    public static let priority_low: JSONKey = "priority-low"
    public static let priority_normal: JSONKey = "priority-normal"
    public static let files_unwanted: JSONKey = "files-unwanted"
    public static let files_wanted: JSONKey = "files-wanted"
    public static let fileStats: JSONKey = "fileStats"
    public static let hashString: JSONKey = "hashString"
    public static let haveUnchecked: JSONKey = "haveUnchecked"
    public static let haveValid: JSONKey = "haveValid"
    public static let honorsSessionLimits: JSONKey = "honorsSessionLimits"
    public static let id: JSONKey = "id"
    public static let isFinished: JSONKey = "isFinished"
    public static let magnetLink: JSONKey = "magnetLink"
    public static let path: JSONKey = "path"
    public static let address: JSONKey = "address"
    public static let clientName: JSONKey = "clientName"
    public static let flagStr: JSONKey = "flagStr"
    public static let isEncrypted: JSONKey = "isEncrypted"
    public static let isUTP: JSONKey = "isUTP"
    public static let port: JSONKey = "port"
    public static let progress: JSONKey = "progress"
    public static let rateToClient: JSONKey = "rateToClient"
    public static let rateToPeer: JSONKey = "rateToPeer"
    public static let peer_limit: JSONKey = "peer-limit"
    public static let peers: JSONKey = "peers"
    public static let peersConnected: JSONKey = "peersConnected"
    public static let peersFrom: JSONKey = "peersFrom"
    public static let fromCache: JSONKey = "fromCache"
    public static let fromDht: JSONKey = "fromDht"
    public static let fromIncoming: JSONKey = "fromIncoming"
    public static let fromLpd: JSONKey = "fromLpd"
    public static let fromLtep: JSONKey = "fromLtep"
    public static let fromPex: JSONKey = "fromPex"
    public static let fromTracker: JSONKey = "fromTracker"
    public static let peersGettingFromUs: JSONKey = "peersGettingFromUs"
    public static let peersSendingToUs: JSONKey = "peersSendingToUs"
    public static let percentDone: JSONKey = "percentDone"
    public static let pieceCount: JSONKey = "pieceCount"
    public static let pieces: JSONKey = "pieces"
    public static let pieceSize: JSONKey = "pieceSize"
    public static let queuePosition: JSONKey = "queuePosition"
    public static let rateDownload: JSONKey = "rateDownload"
    public static let rateUpload: JSONKey = "rateUpload"
    public static let recheckProgress: JSONKey = "recheckProgress"
    public static let secondsDownloading: JSONKey = "secondsDownloading"
    public static let secondsSeeding: JSONKey = "secondsSeeding"
    public static let seedIdleLimit: JSONKey = "seedIdleLimit"
    public static let seedIdleMode: JSONKey = "seedIdleMode"
    public static let seedRatioLimit: JSONKey = "seedRatioLimit"
    public static let seedRatioMode: JSONKey = "seedRatioMode"
    public static let startDate: JSONKey = "startDate"
    public static let status: JSONKey = "status"
    public static let totalSize: JSONKey = "totalSize"
    public static let announce: JSONKey = "announce"
    public static let announceState: JSONKey = "announceState"
    public static let downloadCount: JSONKey = "downloadCount"
    public static let hasAnnounced: JSONKey = "hasAnnounced"
    public static let hasScraped: JSONKey = "hasScraped"
    public static let host: JSONKey = "host"
    public static let location: JSONKey = "location"
    public static let move: JSONKey = "move"
    public static let lastAnnouncePeerCount: JSONKey = "lastAnnouncePeerCount"
    public static let lastAnnounceResult: JSONKey = "lastAnnounceResult"
    public static let lastAnnounceStartTime: JSONKey = "lastAnnounceStartTime"
    public static let lastAnnounceSucceeded: JSONKey = "lastAnnounceSucceeded"
    public static let lastAnnounceTime: JSONKey = "lastAnnounceTime"
    public static let lastAnnounceTimedOut: JSONKey = "lastAnnounceTimedOut"
    public static let lastScrapeResult: JSONKey = "lastScrapeResult"
    public static let lastScrapeStartTime: JSONKey = "lastScrapeStartTime"
    public static let lastScrapeSucceeded: JSONKey = "lastScrapeSucceeded"
    public static let lastScrapeTime: JSONKey = "lastScrapeTime"
    public static let lastScrapeTimedOut: JSONKey = "lastScrapeTimedOut"
    public static let leecherCount: JSONKey = "leecherCount"
    public static let nextAnnounceTime: JSONKey = "nextAnnounceTime"
    public static let nextScrapeTime: JSONKey = "nextScrapeTime"
    public static let scrape: JSONKey = "scrape"
    public static let scrapeState: JSONKey = "scrapeState"
    public static let seederCount: JSONKey = "seederCount"
    public static let tier: JSONKey = "tier"
    public static let trackerAdd: JSONKey = "trackerAdd"
    public static let trackerRemove: JSONKey = "trackerRemove"
    public static let trackerStats: JSONKey = "trackerStats"
    public static let uploadedEver: JSONKey = "uploadedEver"
    public static let uploadLimit: JSONKey = "uploadLimit"
    public static let uploadLimited: JSONKey = "uploadLimited"
    public static let uploadRatio: JSONKey = "uploadRatio"
    public static let size_bytes: JSONKey = "size-bytes"
    public static let ids: JSONKey = "ids"
    public static let recently_active: JSONKey = "recently-active"
    public static let filename: JSONKey = "filename"
    public static let metainfo: JSONKey = "metainfo"
    public static let paused: JSONKey = "paused"
    public static let port_is_open: JSONKey = "port-is-open"
    public static let removed: JSONKey = "removed"
    public static let activeTorrentCount: JSONKey = "activeTorrentCount"
    public static let alt_speed_down: JSONKey = "alt-speed-down"
    public static let alt_speed_enabled: JSONKey = "alt-speed-enabled"
    public static let alt_speed_time_begin: JSONKey = "alt-speed-time-begin"
    public static let alt_speed_time_day: JSONKey = "alt-speed-time-day"
    public static let alt_speed_time_enabled: JSONKey = "alt-speed-time-enabled"
    public static let alt_speed_time_end: JSONKey = "alt-speed-time-end"
    public static let alt_speed_up: JSONKey = "alt-speed-up"
    public static let blocklist_url: JSONKey = "blocklist-url"
    public static let blocklist_size: JSONKey = "blocklist-size"
    public static let blocklist_enabled: JSONKey = "blocklist-enabled"
    public static let cache_size_mb: JSONKey = "cache-size-mb"
    public static let config_dir: JSONKey = "config-dir"
    public static let cumulative_stats: JSONKey = "cumulative-stats"
    public static let current_stats: JSONKey = "current-stats"
    public static let dht_enabled: JSONKey = "dht-enabled"
    public static let download_dir: JSONKey = "download-dir"
    public static let downloadedBytes: JSONKey = "downloadedBytes"
    public static let download_queue_enabled: JSONKey = "download-queue-enabled"
    public static let download_queue_size: JSONKey = "download-queue-size"
    public static let downloadSpeed: JSONKey = "downloadSpeed"
    public static let encryption: JSONKey = "encryption"
    public static let filesAdded: JSONKey = "filesAdded"
    public static let idle_seeding_limit_enabled: JSONKey = "idle-seeding-limit-enabled"
    public static let idle_seeding_limit: JSONKey = "idle-seeding-limit"
    public static let incomplete_dir: JSONKey = "incomplete-dir"
    public static let incomplete_dir_enabled: JSONKey = "incomplete-dir-enabled"
    public static let speed_limit_down: JSONKey = "speed-limit-down"
    public static let speed_limit_down_enabled: JSONKey = "speed-limit-down-enabled"
    public static let speed_limit_up: JSONKey = "speed-limit-up"
    public static let speed_limit_up_enabled: JSONKey = "speed-limit-up-enabled"
    public static let lpd_enabled: JSONKey = "lpd-enabled"
    public static let pausedTorrentCount: JSONKey = "pausedTorrentCount"
    public static let peer_limit_per_torrent: JSONKey = "peer-limit-per-torrent"
    public static let peer_limit_global: JSONKey = "peer-limit-global"
    public static let pex_enabled: JSONKey = "pex-enabled"
    public static let peer_port: JSONKey = "peer-port"
    public static let port_forwarding_enabled: JSONKey = "port-forwarding-enabled"
    public static let peer_port_random_on_start: JSONKey = "peer-port-random-on-start"
    public static let queue_stalled_enabled: JSONKey = "queue-stalled-enabled"
    public static let queue_stalled_minutes: JSONKey = "queue-stalled-minutes"
    public static let rename_partial_files: JSONKey = "rename-partial-files"
    public static let rpc_version: JSONKey = "rpc-version"
    public static let rpc_version_minimum: JSONKey = "rpc-version-minimum"
    public static let script_torrent_done_enabled: JSONKey = "script-torrent-done-enabled"
    public static let script_torrent_done_filename: JSONKey = "script-torrent-done-filename"
    public static let secondsActive: JSONKey = "secondsActive"
    public static let seed_queue_enabled: JSONKey = "seed-queue-enabled"
    public static let seed_queue_size: JSONKey = "seed-queue-size"
    public static let seedRatioLimited: JSONKey = "seedRatioLimited"
    public static let sessionCount: JSONKey = "sessionCount"
    public static let start_added_torrents: JSONKey = "start-added-torrents"
    public static let torrentCount: JSONKey = "torrentCount"
    public static let trash_original_torrent_files: JSONKey = "trash-original-torrent-files"
    public static let uploadedBytes: JSONKey = "uploadedBytes"
    public static let uploadSpeed: JSONKey = "uploadSpeed"
    public static let utp_enabled: JSONKey = "utp-enabled"
    public static let version: JSONKey = "version"
    public static let torrents: JSONKey = "torrents"
    public static let free_space: JSONKey = "free-space"
    public static let session_close: JSONKey = "session-close"
    public static let session_get: JSONKey = "session-get"
    public static let session_set: JSONKey = "session-set"
    public static let session_stats: JSONKey = "session-stats"
    public static let port_test: JSONKey = "port-test"
    public static let torrent_add: JSONKey = "torrent-add"
    public static let torrent_add_url: JSONKey = "torrent-add-url"
    public static let queue_move_bottom: JSONKey = "queue-move-bottom"
    public static let queue_move_down: JSONKey = "queue-move-down"
    public static let torrent_get: JSONKey = "torrent-get"
    public static let torrent_reannounce: JSONKey = "torrent-reannounce"
    public static let torrent_remove: JSONKey = "torrent-remove"
    public static let torrent_set: JSONKey = "torrent-set"
    public static let torrent_rename_path: JSONKey = "torrent-rename-path"
    public static let torrent_start: JSONKey = "torrent-start"
    public static let torrent_start_now: JSONKey = "torrent-start-now"
    public static let torrent_stop: JSONKey = "torrent-stop"
    public static let queue_move_top: JSONKey = "queue-move-top"
    public static let queue_move_up: JSONKey = "queue-move-up"
    public static let torrent_verify: JSONKey = "torrent-verify"
    public static let torrent_set_location: JSONKey = "torrent-set-location"
    public static let arguments: JSONKey = "arguments"
    public static let method: JSONKey = "method"
    public static let result: JSONKey = "result"
    public static let success: JSONKey = "success"
    public static let tag: JSONKey = "tag"
}
