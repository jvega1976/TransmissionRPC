//
//  SessionStats.swift
//  TransmissionRPC
//
//  Created by Johnny Vega on 10/12/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine

//MARK: - SessionStats struct definition
open class SessionStats: NSObject, Decodable, ObservableObject {
    
    @Published public var activeTorrentCount = 0
    @Published public var downloadSpeed = 0
    @Published public var pausedTorrentCount = 0
    @Published public var torrentCount = 0
    @Published public var uploadSpeed = 0
    @Published public var cumulativeUploadedBytes = 0
    @Published public var cumulativedownloadedBytes = 0
    @Published public var cumulativeFilesAdded = 0
    @Published public var cumulativesessionCount = 0
    @Published public var cumulativeSecondsActive: TimeInterval = 0
    @Published public var currentUploadedBytes = 0
    @Published public var currentdownloadedBytes = 0
    @Published public var currentFilesAdded = 0
    @Published public var currentsessionCount = 0
    @Published public var currentSecondsActive: TimeInterval = 0

    private enum CodingKeys: String, CodingKey {
        case activeTorrentCount = "activeTorrentCount"
        case downloadSpeed = "downloadSpeed"
        case pausedTorrentCount = "pausedTorrentCount"
        case torrentCount = "torrentCount"
        case uploadSpeed = "uploadSpeed"
        case cumulativeStats = "cumulative-stats"
        case currentStats = "current-stats"
    }
    
    private enum CumulativeStatsKeys: String, CodingKey {
        case cumulativeUploadedBytes = "uploadedBytes"
        case cumulativedownloadedBytes = "downloadedBytes"
        case cumulativeFilesAdded = "filesAdded"
        case cumulativesessionCount = "sessionCount"
        case cumulativeSecondsActive = "secondsActive"
    }
    
    private enum CurrentStatsKeys: String, CodingKey {
        case currentUploadedBytes = "uploadedBytes"
        case currentdownloadedBytes = "downloadedBytes"
        case currentFilesAdded = "filesAdded"
        case currentsessionCount = "sessionCount"
        case currentSecondsActive = "secondsActive"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        activeTorrentCount = try values.decode(Int.self, forKey: .activeTorrentCount)
        downloadSpeed = try values.decode(Int.self, forKey: .downloadSpeed)
        pausedTorrentCount = try values.decode(Int.self, forKey: .pausedTorrentCount)
        torrentCount = try values.decode(Int.self, forKey: .torrentCount)
        uploadSpeed = try values.decode(Int.self, forKey: .uploadSpeed)
        
        let cumulativeStats = try values.nestedContainer(keyedBy: CumulativeStatsKeys.self, forKey: .cumulativeStats)
        cumulativeUploadedBytes = try cumulativeStats.decode(Int.self, forKey: .cumulativeUploadedBytes)
        cumulativedownloadedBytes = try cumulativeStats.decode(Int.self, forKey: .cumulativedownloadedBytes)
        cumulativeFilesAdded = try cumulativeStats.decode(Int.self, forKey: .cumulativeFilesAdded)
        cumulativesessionCount = try cumulativeStats.decode(Int.self, forKey: .cumulativesessionCount)
        cumulativeSecondsActive = try cumulativeStats.decode(TimeInterval.self, forKey: .cumulativeSecondsActive)
        
        let currentStats = try values.nestedContainer(keyedBy: CurrentStatsKeys.self, forKey: .currentStats)
        currentUploadedBytes = try currentStats.decode(Int.self, forKey: .currentUploadedBytes)
        currentdownloadedBytes = try currentStats.decode(Int.self, forKey: .currentdownloadedBytes)
        currentFilesAdded = try currentStats.decode(Int.self, forKey: .currentFilesAdded)
        currentsessionCount = try currentStats.decode(Int.self, forKey: .currentsessionCount)
        currentSecondsActive = try currentStats.decode(TimeInterval.self, forKey: .currentSecondsActive)
    }
    
    public override init() {
        super.init()
    }
    
    public func update(with stats: SessionStats) {
        self.activeTorrentCount = stats.activeTorrentCount
        self.downloadSpeed = stats.downloadSpeed
        self.pausedTorrentCount = stats.pausedTorrentCount
        self.torrentCount = stats.torrentCount
        self.uploadSpeed = stats.uploadSpeed
        self.cumulativeUploadedBytes = stats.cumulativeUploadedBytes
        self.cumulativedownloadedBytes = stats.cumulativedownloadedBytes
        self.cumulativeFilesAdded = stats.cumulativeFilesAdded
        self.cumulativesessionCount = stats.cumulativesessionCount
        self.cumulativeSecondsActive = stats.cumulativeSecondsActive
        self.currentUploadedBytes = stats.currentUploadedBytes
        self.currentdownloadedBytes = stats.currentdownloadedBytes
        self.currentFilesAdded = stats.currentFilesAdded
        self.currentsessionCount = stats.currentsessionCount
        self.currentSecondsActive = stats.currentSecondsActive
    }
}


