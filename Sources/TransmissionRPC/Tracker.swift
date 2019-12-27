//
//  Tracker.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

//MARK: - Enumerations
public enum TrackerState: Int, Codable
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
    
    public static func stringValue(_ rawValue: RawValue) -> String {
        let state = TrackerState(rawValue: rawValue)
        switch state {
            case .inactive:
                return "Inactive"
            case .waiting:
                return "Waiting"
            case .queued:
                return "Queued"
            case .active:
                return "Active"
            case .none:
                return ""
        }
    }
}

//MARK: - Tracker struct definition
open class Tracker: NSObject, Codable {

    public var announce: String = ""
    public var announceState: TrackerState.RawValue = TrackerState.inactive.rawValue
    public var downloadCount:Int = 0
    public var hasAnnounced: Bool = false
    public var hasScraped: Bool = false
    public var host: String = ""
    public var trackerId: Int = 0
    public var isBackup: Bool = false
    public var lastAnnouncePeerCount: Int = 0
    public var lastAnnounceResult: String = ""
    public var lastAnnounceStartTime: TimeInterval = 0
    public var lastAnnounceSucceeded: Bool = false
    public var lastAnnounceTime: TimeInterval = 0
    public var lastAnnounceTimedOut: Bool = false
    public var lastScrapeResult: String = ""
    public var lastScrapeStartTime: TimeInterval = 0
    public var lastScrapeSucceeded: Bool = false
    public var lastScrapeTime: TimeInterval = 0
    public var lastScrapeTimedOut: TimeInterval = 0
    public var leecherCount: Int = 0
    public var nextAnnounceTime: TimeInterval = 0
    public var nextScrapeTime: TimeInterval = 0
    public var scrape: String = ""
    public var scrapeState: Int = 0
    public var seederCount: Int = 0
    public var tier: Int = 0
   
    open var lastAnnounceTimeString: String {
        return formatDateFrom1970Short(lastAnnounceTime) ?? ""
    }
    open var lastScrapeTimeString: String {
        return formatDateFrom1970Short(lastScrapeTime) ?? ""
    }
    open var nextAnnounceTimeString: String {
        return formatDateFrom1970Short(nextAnnounceTime) ?? ""
    }
    open var nextScrapeTimeString: String {
        return formatDateFrom1970Short(nextScrapeTime) ?? ""
    }
    
    open var lastAnnounceStartTimeString: String {
        return formatDateFrom1970Short(lastAnnounceStartTime) ?? ""
    }
    
    open var lastScrapeStartTimeString: String {
        return formatDateFrom1970Short(lastScrapeStartTime) ?? ""
    }
    
    open var announceString: String {
        return TrackerState.stringValue(self.announceState)
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
    
}
