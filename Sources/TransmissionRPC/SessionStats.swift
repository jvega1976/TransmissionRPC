//
//  SessionStats.swift
//  TransmissionRPC
//
//  Created by Johnny Vega on 10/12/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

//MARK: - SessionStats struct definition
public struct SessionStats: Decodable {
    
    public var activeTorrentCount = 0
    public var downloadSpeed = 0
    public var pausedTorrentCount = 0
    public var torrentCount = 0
    public var uploadSpeed = 0
    public var cumulativeUploadedBytes = 0
    public var cumulativedownloadedBytes = 0
    public var cumulativeFilesAdded = 0
    public var cumulativesessionCount = 0
    public var cumulativeSecondsActive: TimeInterval = 0
    public var currentUploadedBytes = 0
    public var currentdownloadedBytes = 0
    public var currentFilesAdded = 0
    public var currentsessionCount = 0
    public var currentSecondsActive: TimeInterval = 0

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
    
    public init(from decoder: Decoder) throws {
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
}


