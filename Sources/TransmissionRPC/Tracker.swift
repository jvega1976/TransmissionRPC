//
//  Tracker.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

//MARK: - Enumerations
@objc public enum TrackerState: Int, Codable
{
    /* we won't (announce,scrape) this torrent to this tracker because
     * the torrent is stopped, or because of an error, or whatever */
    case inactive = 0
    /* we will (announce,scrape) this torrent to this tracker, and are
     * waiting for enough time to pass to satisfy the tracker's interval */
    case waiting = 1
    /* it's time to (announce,scrape) this torrent, and we're waiting on a
     * a free slot to open up in the announce manager */
    case queued = 2
    /* we're (announcing,scraping) this torrent right now */
    case active = 3
    
    public var stringValue: String {
        switch self {
            case .inactive:
                return "Inactive"
            case .waiting:
                return "Waiting"
            case .queued:
                return "Queued"
            case .active:
                return "Active"
            default:
                return ""
        }
    }
}

//MARK: - Tracker struct definition
open class Tracker: NSObject, Codable, ObservableObject, Identifiable  {

    @Published public var announce: String = "http://server.unknown.com:9999"
    @Published public var announceState: TrackerState = TrackerState.inactive
    @Published public var downloadCount:Int = 0
    @Published public var hasAnnounced: Bool = false
    @Published public var hasScraped: Bool = false
    @Published public var host: String = "server.unknown.com"
    @Published public var trackerId: Int = 0
    @Published public var isBackup: Bool = false
    @Published public var lastAnnouncePeerCount: Int = 0
    @Published public var lastAnnounceResult: String = "Unknown"
    @Published public var lastAnnounceStartTime: TimeInterval = 0
    @Published public var lastAnnounceSucceeded: Bool = false
    @Published public var lastAnnounceTime: TimeInterval = 0
    @Published public var lastAnnounceTimedOut: Bool = false
    @Published public var lastScrapeResult: String = ""
    @Published public var lastScrapeStartTime: TimeInterval = 0
    @Published public var lastScrapeSucceeded: Bool = false
    @Published public var lastScrapeTime: TimeInterval = 0
    @Published public var lastScrapeTimedOut: TimeInterval = 0
    @Published public var leecherCount: Int = 0
    @Published public var nextAnnounceTime: TimeInterval = 0
    @Published public var nextScrapeTime: TimeInterval = 0
    @Published public var scrape: String = "Unknown"
    @Published public var scrapeState: Int = 0
    @Published public var seederCount: Int = 0
    @Published public var tier: Int = 0
    
    public var id: Int {
        return trackerId
    }
   
    open var lastAnnounceTimeString: String {
        return DateFormatter.formatDateFrom1970Short(lastAnnounceTime)
    }
    open var lastScrapeTimeString: String {
        return DateFormatter.formatDateFrom1970Short(lastScrapeTime)
    }
    open var nextAnnounceTimeString: String {
        return DateFormatter.formatDateFrom1970Short(nextAnnounceTime)
    }
    open var nextScrapeTimeString: String {
        return DateFormatter.formatDateFrom1970Short(nextScrapeTime)
    }
    
    open var lastAnnounceStartTimeString: String {
        return DateFormatter.formatDateFrom1970Short(lastAnnounceStartTime)
    }
    
    open var lastScrapeStartTimeString: String {
        return DateFormatter.formatDateFrom1970Short(lastScrapeStartTime)
    }
    
    open var announceString: String {
        return self.announceState.stringValue
    }
   
    private enum CodingKeys: String, CodingKey {
        case announce
        case announceState
        case downloadCount
        case hasAnnounced
        case hasScraped
        case host
        case trackerId = "id"
        case isBackup
        case lastAnnouncePeerCount
        case lastAnnounceResult
        case lastAnnounceStartTime
        case lastAnnounceSucceeded
        case lastAnnounceTime
        case lastAnnounceTimedOut
        case lastScrapeResult
        case lastScrapeStartTime
        case lastScrapeSucceeded
        case lastScrapeTime
        case lastScrapeTimedOut
        case leecherCount
        case nextAnnounceTime
        case nextScrapeTime
        case scrape
        case scrapeState
        case seederCount
        case tier
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        announce = try values.decode(String.self, forKey: .announce)
        announceState = try values.decode(TrackerState.self, forKey: .announceState)
        downloadCount = try values.decode(Int.self, forKey: .downloadCount)
        hasAnnounced = try values.decode(Bool.self, forKey: .hasAnnounced)
        hasScraped = try values.decode(Bool.self, forKey: .hasScraped)
        host = try values.decode(String.self, forKey: .host)
        trackerId = try values.decode(Int.self, forKey: .trackerId)
        isBackup = try values.decode(Bool.self, forKey: .isBackup)
        lastAnnouncePeerCount = try values.decode(Int.self, forKey: .lastAnnouncePeerCount)
        lastAnnounceResult = try values.decode(String.self, forKey: .lastAnnounceResult)
        lastAnnounceStartTime = try values.decode(TimeInterval.self, forKey: .lastAnnounceStartTime)
        lastAnnounceSucceeded = try values.decode(Bool.self, forKey: .lastAnnounceSucceeded)
        lastAnnounceTime = try values.decode(TimeInterval.self, forKey: .lastAnnounceTime)
        lastAnnounceTimedOut = try values.decode(Bool.self, forKey: .lastAnnounceTimedOut)
        lastScrapeResult = try values.decode(String.self, forKey: .lastScrapeResult)
        lastScrapeStartTime = try values.decode(TimeInterval.self, forKey: .lastScrapeStartTime)
        lastScrapeSucceeded = try values.decode(Bool.self, forKey: .lastScrapeSucceeded)
        lastScrapeTime = try values.decode(TimeInterval.self, forKey: .lastScrapeTime)
        lastScrapeTimedOut = try values.decode(TimeInterval.self, forKey: .lastScrapeTimedOut)
        leecherCount = try values.decode(Int.self, forKey: .leecherCount)
        nextAnnounceTime = try values.decode(TimeInterval.self, forKey: .nextAnnounceTime)
        nextScrapeTime = try values.decode(TimeInterval.self, forKey: .nextScrapeTime)
        scrape = try values.decode(String.self, forKey: .scrape)
        scrapeState = try values.decode(Int.self, forKey: .scrapeState)
        seederCount = try values.decode(Int.self, forKey: .seederCount)
        tier = try values.decode(Int.self, forKey: .tier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(announce, forKey: .announce)
        try container.encode(announceState, forKey: .announceState)
        try container.encode(downloadCount, forKey: .downloadCount)
        try container.encode(hasAnnounced, forKey: .hasAnnounced)
        try container.encode(hasScraped, forKey: .hasScraped)
        try container.encode(host, forKey: .host)
        try container.encode(trackerId, forKey: .trackerId)
        try container.encode(isBackup, forKey: .isBackup)
        try container.encode(lastAnnouncePeerCount, forKey: .lastAnnouncePeerCount)
        try container.encode(lastAnnounceResult, forKey: .lastAnnounceResult)
        try container.encode(lastAnnounceStartTime, forKey: .lastAnnounceStartTime)
        try container.encode(lastAnnounceSucceeded, forKey: .lastAnnounceSucceeded)
        try container.encode(lastAnnounceTime, forKey: .lastAnnounceTime)
        try container.encode(lastAnnounceTimedOut, forKey: .lastAnnounceTimedOut)
        try container.encode(lastScrapeResult, forKey: .lastScrapeResult)
        try container.encode(lastScrapeStartTime, forKey: .lastScrapeStartTime)
        try container.encode(lastScrapeSucceeded, forKey: .lastScrapeSucceeded)
        try container.encode(lastScrapeTime, forKey: .lastScrapeTime)
        try container.encode(lastScrapeTimedOut, forKey: .lastScrapeTimedOut)
        try container.encode(leecherCount, forKey: .leecherCount)
        try container.encode(nextAnnounceTime, forKey: .nextAnnounceTime)
        try container.encode(nextScrapeTime, forKey: .nextScrapeTime)
        try container.encode(scrape, forKey: .scrape)
        try container.encode(scrapeState, forKey: .scrapeState)
        try container.encode(seederCount, forKey: .seederCount)
        try container.encode(tier, forKey: .tier)
    }
    
    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        return lhs.trackerId == rhs.trackerId
    }
    
    
    static func != (lhs: Tracker, rhs: Tracker) -> Bool {
        return lhs.trackerId != rhs.trackerId
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        return self.trackerId == (object as? Tracker)?.trackerId
    }
}


