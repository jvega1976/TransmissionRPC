//
//  SessionConfig.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

//MARK: - Enumerations
public enum Encryption: String, Codable {
    case required = "required"
    case preferred = "preferred"
    case tolerated = "tolerated"
    
    public init(_ encript: Int) {
        switch encript {
            case 0:
                self = .required
            case 1:
                self = .preferred
            case 2:
                self = .tolerated
            default:
                self = .tolerated
        }
    }
    
    public var intVal: Int {
        switch self {
            case .required:
                return 0
            case .preferred:
                return 1
            case .tolerated:
                return 2
        }
    }
}


//MARK: - SessionConfig struct definition
public struct SessionConfig: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case altDownloadRateLimit = "alt-speed-down"
        case altLimitEnabled = "alt-speed-enabled"
        case altLimitTimeBegin = "alt-speed-time-begin"
        case altLimitDay = "alt-speed-time-day"
        case altLimitTimeEnabled = "alt-speed-time-enabled"
        case altLimitTimeEnd = "alt-speed-time-end"
        case altUploadRateLimit = "alt-speed-up"
        case blocklistEnabled = "blocklist-enabled"
        case blocklistSize = "blocklist-size"
        case blocklistURL = "blocklist-url"
        case cacheSizeMb = "cache-size-mb"
        case configDir = "config-dir"
        case dhtEnabled = "dht-enabled"
        case downloadDir = "download-dir"
        case downloadQueueEnabled = "download-queue-enabled"
        case downloadQueueSize = "download-queue-size"
        case encryption = "encryption"
        case seedIdleLimit = "idle-seeding-limit"
        case seedIdleLimitEnabled = "idle-seeding-limit-enabled"
        case incompletedDir = "incomplete-dir"
        case incompletedDirEnabled = "incomplete-dir-enabled"
        case lpdEnabled = "lpd-enabled"
        case globalPeerLimit = "peer-limit-global"
        case torrentPeerLimit = "peer-limit-per-torrent"
        case port = "peer-port"
        case portRandomAtStartEnabled = "peer-port-random-on-start"
        case pexEnabled = "pex-enabled"
        case portForfardingEnabled = "port-forwarding-enabled"
        case queueStalledEnabled = "queue-stalled-enabled"
        case queueStalledMinutes = "queue-stalled-minutes"
        case addPartToUnfinishedFilesEnabled = "rename-partial-files"
        case rpcVersion = "rpc-version"
        case rpcVersionMinimum = "rpc-version-minimum"
        case scriptTorrentDoneEnabled = "script-torrent-done-enabled"
        case scriptTorrentDoneFile = "script-torrent-done-filename"
        case seedQueueEnabled = "seed-queue-enabled"
        case seedQueueSize = "seed-queue-size"
        case seedRatioLimit = "seedRatioLimit"
        case seedRatioLimitEnabled = "seedRatioLimited"
        case downLimitRate = "speed-limit-down"
        case downLimitEnabled = "speed-limit-down-enabled"
        case upLimitRate = "speed-limit-up"
        case upLimitEnabled = "speed-limit-up-enabled"
        case startDownloadingOnAdd = "start-added-torrents"
        case trashOriginalTorrentFile = "trash-original-torrent-files"
        case utpEnabled = "utp-enabled"
        case transmissionVersion = "version"
    }
    
    public var transmissionVersion = ""
    public var rpcVersion = 0
    public var downloadDir = ""
    public var incompletedDirEnabled = false
    public var incompletedDir = ""
    public var scriptTorrentDoneEnabled = false
    public var scriptTorrentDoneFile = ""
    public var downloadQueueEnabled = false
    public var downloadQueueSize = 0
    public var seedQueueEnabled = false
    public var seedQueueSize = 0
    public var queueStalledEnabled = false
    public var queueStalledMinutes = 0
    public var startDownloadingOnAdd = false
    public var trashOriginalTorrentFile = false
    public var upLimitEnabled = false
    public var downLimitEnabled = false
    public var upLimitRate = 0
    public var downLimitRate = 0
    public var seedRatioLimitEnabled = false
    public var seedRatioLimit = 0.0
    public var portForfardingEnabled = false
    public var portRandomAtStartEnabled = false
    public var port = 0
    public var utpEnabled = false
    public var pexEnabled = false
    public var lpdEnabled = false
    public var dhtEnabled = false
    public var globalPeerLimit  = 0
    public var torrentPeerLimit  = 0
    public var encryption: Encryption = .preferred
    public var addPartToUnfinishedFilesEnabled = false
    public var blocklistEnabled = false
    public var blocklistURL = ""
    public var seedIdleLimit = 0
    public var seedIdleLimitEnabled = false
    public var altLimitEnabled = false
    public var altDownloadRateLimit = 0
    public var altUploadRateLimit = 0
    public var altLimitTimeEnabled = false
    public var altLimitTimeBegin = 0
    public var altLimitTimeEnd = 0
    public var cacheSizeMb = 0
    public var configDir = ""
    public var rpcVersionMinimum = 0
    public var blocklistSize = 0
    private var selectedDays = [Bool]()
    private var firstTime: Bool = true

    public var encryptionId: Int {
        mutating set(encript) {
            encryption = Encryption(encript)
        }
        get {
            encryption.intVal
        }
    }

    public var altLimitDay: Int {
        didSet {
            if firstTime {
                fillSelectedDays()
                firstTime = false
            }
        }
    }


    public var altLimitSun: Bool {
        get {
            return (selectedDays[0])
        }
        set(altLimitSun) {
            selectedDays[0] = altLimitSun
            deriveAltLimitDay()
        }
    }

    
    public var altLimitMon: Bool {
        get {
            return (selectedDays[1])
        }
        set(altLimitMon) {
            selectedDays[1] = altLimitMon
            deriveAltLimitDay()
        }
    }

    
    public var altLimitTue: Bool {
        get {
            return (selectedDays[2])
        }
        set(altLimitTue) {
            selectedDays[2] = altLimitTue
            deriveAltLimitDay()
        }
    }

    
    public var altLimitWed: Bool {
        get {
            return (selectedDays[3])
        }
        set(altLimitWed) {
            selectedDays[3] = altLimitWed
            deriveAltLimitDay()
        }
    }

    
    public var altLimitThu: Bool {
        get {
            return (selectedDays[4])
        }
        set(altLimitThu) {
            selectedDays[4] = altLimitThu
            deriveAltLimitDay()
        }
    }

    
    public var altLimitFri: Bool {
        get {
            return (selectedDays[5])
        }
        set(altLimitFri) {
            selectedDays[5] = altLimitFri
            deriveAltLimitDay()
        }
    }

    
    public var altLimitSat: Bool {
        get {
            return (selectedDays[6])
        }
        set(altLimitSat) {
            selectedDays[6] = altLimitSat
            deriveAltLimitDay()
        }
    }

    
    public var limitTimeBegin: Date? {
        get {

            let c = Calendar.current
            var cp: DateComponents = c.dateComponents([.nanosecond], from: Date())
            cp.hour = altLimitTimeBegin
            cp.minute = altLimitTimeBegin

            return c.date(from: cp)
        }
        set(limitTimeBegin) {
            let dt = limitTimeBegin

            let cal = Calendar.current
            var c: DateComponents? = nil
            if(dt != nil){
                c = cal.dateComponents([.hour, .minute], from: dt!)
            }

            altLimitTimeBegin = c!.hour! * 60 + c!.minute!
        }
    }

    
    public var limitTimeEnd: Date? {
        get {
            let c = Calendar.current
            var cp: DateComponents = c.dateComponents([.nanosecond], from: Date())
            cp.hour = altLimitTimeEnd
            cp.minute = altLimitTimeEnd

            return c.date(from: cp)
        }
        set(limitTimeEnd) {

            let dt = limitTimeEnd

            let cal = Calendar.current
            var c: DateComponents? = nil
            if (dt != nil) {
                c = cal.dateComponents([.hour, .minute], from: dt!)
            }

            altLimitTimeEnd = c!.hour! * 60 + c!.minute!
        }
    }
    
    
    public var jsonForRPC: JSONObject {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(self)
        //print(String(data: data, encoding: .utf8) ?? "")
        var json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONObject
        //dump(json)
        json.removeValue(forKey: JSONKeys.rpc_version)
        json.removeValue(forKey: JSONKeys.rpc_version_minimum)
        json.removeValue(forKey: JSONKeys.config_dir)
        json.removeValue(forKey: JSONKeys.blocklist_size)
        json.removeValue(forKey: JSONKeys.version)
        return json
    }
    
    
    public func fillSelectedDays() {
        
        var dec = altLimitDay
        var selectedDays = [Bool]()
        for i in 0..<7 {
            selectedDays.insert(((dec % 2) != 0) ? true: false, at: i)
                dec = dec / 2
        }
    }

    
    public mutating func deriveAltLimitDay() {
        var tmpLimitDay = 0
        for i in 0..<7 {
            let n = Int(pow(2, Double(i)))
            let isSel = selectedDays[i] as Bool
            let x = (isSel) ? 1 : 0
            tmpLimitDay = tmpLimitDay + (x * n)
        }
        altLimitDay = tmpLimitDay
    }
    
}
