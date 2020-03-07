//
//  SessionConfig.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine


/*public struct AltDays
{
    public static var Sunday = 1 << 0
    public static var Monday = 1 << 1
    public static var Tuesday = 1 << 2
    public static var Wednesday = 1 << 3
    public static var Thursday = 1 << 4
    public static var Friday = 1 << 5
    public static var Saturday = 1 << 6
    public static var Weekday = AltDays.Monday | AltDays.Tuesday | AltDays.Wednesday | AltDays.Thursday | AltDays.Friday
    public static var Weekend = AltDays.Sunday | AltDays.Saturday
    public static var All = AltDays.Sunday | AltDays.Monday | AltDays.Tuesday | AltDays.Wednesday | AltDays.Thursday | AltDays.Friday | AltDays.Saturday
    
    public static func day(_ i: Int) -> Int {
        switch i {
            case 0..<7:
                return 1 << i
            case 7:
                return Weekend
            case 8:
                return Weekday
            case 9:
                return All
            default:
                return 0
        }
    }
}
*/

//MARK: - SessionConfig struct definition
open class SessionConfig: NSObject, Codable, ObservableObject {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case altSpeedDown = "alt-speed-down"
        case altSpeedEnabled = "alt-speed-enabled"
        case altSpeedTimeBegin = "alt-speed-time-begin"
        case altSpeedTimeDay = "alt-speed-time-day"
        case altSpeedTimeEnabled = "alt-speed-time-enabled"
        case altSpeedTimeEnd = "alt-speed-time-end"
        case altSpeedUp = "alt-speed-up"
        case blocklistEnabled = "blocklist-enabled"
        case blocklistSize = "blocklist-size"
        case blocklistUrl = "blocklist-url"
        case cacheSizeMb = "cache-size-mb"
        case configDir = "config-dir"
        case dhtEnabled = "dht-enabled"
        case downloadDir = "download-dir"
        case downloadQueueEnabled = "download-queue-enabled"
        case downloadQueueSize = "download-queue-size"
        case encryption = "encryption"
        case idleSeedingLimit = "idle-seeding-limit"
        case idleSeedingLimitEnabled = "idle-seeding-limit-enabled"
        case incompletedDir = "incomplete-dir"
        case incompletedDirEnabled = "incomplete-dir-enabled"
        case lpdEnabled = "lpd-enabled"
        case peerLimitGlobal = "peer-limit-global"
        case peerLimitPerTorrent = "peer-limit-per-torrent"
        case peerPort = "peer-port"
        case peerPortRandomOnStart = "peer-port-random-on-start"
        case pexEnabled = "pex-enabled"
        case portForfardingEnabled = "port-forwarding-enabled"
        case queueStalledEnabled = "queue-stalled-enabled"
        case queueStalledMinutes = "queue-stalled-minutes"
        case renamePartialFiles = "rename-partial-files"
        case rpcVersion = "rpc-version"
        case rpcVersionMinimum = "rpc-version-minimum"
        case scriptTorrentDoneEnabled = "script-torrent-done-enabled"
        case scriptTorrentDoneFilename = "script-torrent-done-filename"
        case seedQueueEnabled = "seed-queue-enabled"
        case seedQueueSize = "seed-queue-size"
        case seedRatioLimit = "seedRatioLimit"
        case seedRatioLimited = "seedRatioLimited"
        case speedLimitDown = "speed-limit-down"
        case speedLimitDownEnabled = "speed-limit-down-enabled"
        case speedLimitUp = "speed-limit-up"
        case speedLimitUpEnabled = "speed-limit-up-enabled"
        case startAddedTorrents = "start-added-torrents"
        case trashOriginalTorrentFiles = "trash-original-torrent-files"
        case utpEnabled = "utp-enabled"
        case version = "version"
    }
    
    @Published public var version: String  = ""
    @Published public var rpcVersion: Int = 0
    @Published public var downloadDir: String = ""
    @Published public var incompletedDirEnabled: Bool = false
    @Published public var incompletedDir: String = ""
    @Published public var scriptTorrentDoneEnabled: Bool = false
    @Published public var scriptTorrentDoneFilename: String = ""
    @Published public var downloadQueueEnabled: Bool = false
    @Published public var downloadQueueSize: Int = 0
    @Published public var seedQueueEnabled: Bool = false
    @Published public var seedQueueSize: Int = 0
    @Published public var queueStalledEnabled: Bool = false
    @Published public var queueStalledMinutes: Int = 0
    @Published public var startAddedTorrents: Bool = false
    @Published public var trashOriginalTorrentFiles: Bool = false
    @Published public var speedLimitUpEnabled: Bool = false
    @Published public var speedLimitDownEnabled: Bool = false
    @Published public var speedLimitUp: Int = 0
    @Published public var speedLimitDown: Int = 0
    @Published public var seedRatioLimited: Bool = false
    @Published public var seedRatioLimit: Double = 0.0
    @Published public var portForfardingEnabled: Bool = false
    @Published public var peerPortRandomOnStart: Bool = false
    @Published public var peerPort: Int = 0
    @Published public var utpEnabled: Bool = false
    @Published public var pexEnabled: Bool = false
    @Published public var lpdEnabled: Bool = false
    @Published public var dhtEnabled: Bool = false
    @Published public var peerLimitGlobal: Int  = 0
    @Published public var peerLimitPerTorrent: Int  = 0
    @Published public var encryption: String = "" {
        didSet {
             if oldValue != encryption {
                switch(encryption) {
                    case "required":
                        self.encryptionInt = 0
                    case "preferred":
                        self.encryptionInt = 1
                    case "tolerated":
                        self.encryptionInt = 2
                    default:
                        self.encryptionInt = 2
                }
            }
        }
    }
    @Published public var renamePartialFiles: Bool = false
    @Published public var blocklistEnabled: Bool = false
    @Published public var blocklistUrl: String = ""
    @Published public var idleSeedingLimit: Int = 0
    @Published public var idleSeedingLimitEnabled: Bool = false
    @Published public var altSpeedEnabled: Bool = false
    @Published public var altSpeedDown: Int = 0
    @Published public var altSpeedUp: Int = 0
    @Published public var altSpeedTimeEnabled: Bool = false
    @Published public var altSpeedTimeBegin: Int = 0
    @Published public var altSpeedTimeEnd: Int = 0
    @Published public var altSpeedTimeDay: Int = 0
    @Published public var cacheSizeMb: Int = 0
    @Published public var configDir: String = ""
    @Published public var rpcVersionMinimum: Int = 0
    @Published public var blocklistSize: Int = 0
    @Published public var encryptionInt: Int = 0 {
        didSet {
            if oldValue != encryptionInt {
                switch(encryptionInt) {
                    case 0:
                        self.encryption = "required"
                    case 1:
                        self.encryption = "preferred"
                    case 2:
                        self.encryption = "tolerated"
                    default:
                        self.encryption = "tolerated"
                }
            }
        }
    }
    //private lazy var selectedDays = fillSelectedDays()
    //private var firstTime: Bool = true

    public override init() {
        super.init()
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.rpcVersion, forKey: .rpcVersion)
        try container.encode(self.downloadDir, forKey: .downloadDir)
        try container.encode(self.incompletedDirEnabled, forKey: .incompletedDirEnabled)
        try container.encode(self.incompletedDir, forKey: .incompletedDir)
        try container.encode(self.scriptTorrentDoneEnabled, forKey: .scriptTorrentDoneEnabled)
        try container.encode(self.scriptTorrentDoneFilename, forKey: .scriptTorrentDoneFilename)
        try container.encode(self.downloadQueueEnabled, forKey: .downloadQueueEnabled)
        try container.encode(self.downloadQueueSize, forKey: .downloadQueueSize)
        try container.encode(self.seedQueueEnabled, forKey: .seedQueueEnabled)
        try container.encode(self.seedQueueSize, forKey: .seedQueueSize)
        try container.encode(self.queueStalledEnabled, forKey: .queueStalledEnabled)
        try container.encode(self.queueStalledMinutes, forKey: .queueStalledMinutes)
        try container.encode(self.startAddedTorrents, forKey: .startAddedTorrents)
        try container.encode(self.trashOriginalTorrentFiles, forKey: .trashOriginalTorrentFiles)
        try container.encode(self.speedLimitUpEnabled, forKey: .speedLimitUpEnabled)
        try container.encode(self.speedLimitDownEnabled, forKey: .speedLimitDownEnabled)
        try container.encode(self.speedLimitUp, forKey: .speedLimitUp)
        try container.encode(self.speedLimitDown, forKey: .speedLimitDown)
        try container.encode(self.seedRatioLimited, forKey: .seedRatioLimited)
        try container.encode(self.seedRatioLimit, forKey: .seedRatioLimit)
        try container.encode(self.portForfardingEnabled, forKey: .portForfardingEnabled)
        try container.encode(self.peerPortRandomOnStart, forKey: .peerPortRandomOnStart)
        try container.encode(self.peerPort, forKey: .peerPort)
        try container.encode(self.utpEnabled, forKey: .utpEnabled)
        try container.encode(self.pexEnabled, forKey: .pexEnabled)
        try container.encode(self.lpdEnabled, forKey: .lpdEnabled)
        try container.encode(self.dhtEnabled, forKey: .dhtEnabled)
        try container.encode(self.peerLimitGlobal, forKey: .peerLimitGlobal)
        try container.encode(self.peerLimitPerTorrent, forKey: .peerLimitPerTorrent)
        try container.encode(self.encryption, forKey: .encryption)
        try container.encode(self.renamePartialFiles, forKey: .renamePartialFiles)
        try container.encode(self.blocklistEnabled, forKey: .blocklistEnabled)
        try container.encode(self.blocklistUrl, forKey: .blocklistUrl)
        try container.encode(self.idleSeedingLimit, forKey: .idleSeedingLimit)
        try container.encode(self.idleSeedingLimitEnabled, forKey: .idleSeedingLimitEnabled)
        try container.encode(self.altSpeedEnabled, forKey: .altSpeedEnabled)
        try container.encode(self.altSpeedDown, forKey: .altSpeedDown)
        try container.encode(self.altSpeedUp, forKey: .altSpeedUp)
        try container.encode(self.altSpeedTimeEnabled, forKey: .altSpeedTimeEnabled)
        try container.encode(self.altSpeedTimeBegin, forKey: .altSpeedTimeBegin)
        try container.encode(self.altSpeedTimeEnd, forKey: .altSpeedTimeEnd)
        try container.encode(self.altSpeedTimeDay, forKey: .altSpeedTimeDay)
        try container.encode(self.cacheSizeMb, forKey: .cacheSizeMb)
        try container.encode(self.configDir, forKey: .configDir)
        try container.encode(self.rpcVersionMinimum, forKey: .rpcVersionMinimum)
        try container.encode(self.blocklistSize, forKey: .blocklistSize)
        
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try values.decode(String.self, forKey: .version)
        self.rpcVersion = try values.decode(Int.self, forKey: .rpcVersion)
        self.downloadDir = try values.decode(String.self, forKey: .downloadDir)
        self.incompletedDirEnabled = try values.decode(Bool.self, forKey: .incompletedDirEnabled)
        self.incompletedDir = try values.decode(String.self, forKey: .incompletedDir)
        self.scriptTorrentDoneEnabled = try values.decode(Bool.self, forKey: .scriptTorrentDoneEnabled)
        self.scriptTorrentDoneFilename = try values.decode(String.self, forKey: .scriptTorrentDoneFilename)
        self.downloadQueueEnabled = try values.decode(Bool.self, forKey: .downloadQueueEnabled)
        self.downloadQueueSize = try values.decode(Int.self, forKey: .downloadQueueSize)
        self.seedQueueEnabled = try values.decode(Bool.self, forKey: .seedQueueEnabled)
        self.seedQueueSize = try values.decode(Int.self, forKey: .seedQueueSize)
        self.queueStalledEnabled = try values.decode(Bool.self, forKey: .queueStalledEnabled)
        self.queueStalledMinutes = try values.decode(Int.self, forKey: .queueStalledMinutes)
        self.startAddedTorrents = try values.decode(Bool.self, forKey: .startAddedTorrents)
        self.trashOriginalTorrentFiles = try values.decode(Bool.self, forKey: .trashOriginalTorrentFiles)
        self.speedLimitUpEnabled = try values.decode(Bool.self, forKey: .speedLimitUpEnabled)
        self.speedLimitDownEnabled = try values.decode(Bool.self, forKey: .speedLimitDownEnabled)
        self.speedLimitUp = try values.decode(Int.self, forKey: .speedLimitUp)
        self.speedLimitDown = try values.decode(Int.self, forKey: .speedLimitDown)
        self.seedRatioLimited = try values.decode(Bool.self, forKey: .seedRatioLimited)
        self.seedRatioLimit = try values.decode(Double.self, forKey: .seedRatioLimit)
        self.portForfardingEnabled = try values.decode(Bool.self, forKey: .portForfardingEnabled)
        self.peerPortRandomOnStart = try values.decode(Bool.self, forKey: .peerPortRandomOnStart)
        self.peerPort = try values.decode(Int.self, forKey: .peerPort)
        self.utpEnabled = try values.decode(Bool.self, forKey: .utpEnabled)
        self.pexEnabled = try values.decode(Bool.self, forKey: .pexEnabled)
        self.lpdEnabled = try values.decode(Bool.self, forKey: .lpdEnabled)
        self.dhtEnabled = try values.decode(Bool.self, forKey: .dhtEnabled)
        self.peerLimitGlobal = try values.decode(Int.self, forKey: .peerLimitGlobal)
        self.peerLimitPerTorrent = try values.decode(Int.self, forKey: .peerLimitPerTorrent)
        self.encryption = try values.decode(String.self, forKey: .encryption)
        self.renamePartialFiles = try values.decode(Bool.self, forKey: .renamePartialFiles)
        self.blocklistEnabled = try values.decode(Bool.self, forKey: .blocklistEnabled)
        self.blocklistUrl = try values.decode(String.self, forKey: .blocklistUrl)
        self.idleSeedingLimit = try values.decode(Int.self, forKey: .idleSeedingLimit)
        self.idleSeedingLimitEnabled = try values.decode(Bool.self, forKey: .idleSeedingLimitEnabled)
        self.altSpeedEnabled = try values.decode(Bool.self, forKey: .altSpeedEnabled)
        self.altSpeedDown = try values.decode(Int.self, forKey: .altSpeedDown)
        self.altSpeedUp = try values.decode(Int.self, forKey: .altSpeedUp)
        self.altSpeedTimeEnabled = try values.decode(Bool.self, forKey: .altSpeedTimeEnabled)
        self.altSpeedTimeBegin = try values.decode(Int.self, forKey: .altSpeedTimeBegin)
        self.altSpeedTimeEnd = try values.decode(Int.self, forKey: .altSpeedTimeEnd)
        self.altSpeedTimeDay = try values.decode(Int.self, forKey: .altSpeedTimeDay)
        self.cacheSizeMb = try values.decode(Int.self, forKey: .cacheSizeMb)
        self.configDir = try values.decode(String.self, forKey: .configDir)
        self.rpcVersionMinimum = try values.decode(Int.self, forKey: .rpcVersionMinimum)
        self.blocklistSize = try values.decode(Int.self, forKey: .blocklistSize)
    }
    
    public class func propertyStringName(stringValue string: String) -> String? {
        return CodingKeys.allCases.first(where: {key in
            return key.rawValue.camelCased == string})?.rawValue
    }
   
    public func update(with session: SessionConfig) {
        self.version = session.version
        self.rpcVersion = session.rpcVersion
        self.downloadDir = session.downloadDir
        self.incompletedDirEnabled = session.incompletedDirEnabled
        self.incompletedDir = session.incompletedDir
        self.scriptTorrentDoneEnabled = session.scriptTorrentDoneEnabled
        self.scriptTorrentDoneFilename = session.scriptTorrentDoneFilename
        self.downloadQueueEnabled = session.downloadQueueEnabled
        self.downloadQueueSize = session.downloadQueueSize
        self.seedQueueEnabled = session.seedQueueEnabled
        self.seedQueueSize = session.seedQueueSize
        self.queueStalledEnabled = session.queueStalledEnabled
        self.queueStalledMinutes = session.queueStalledMinutes
        self.startAddedTorrents = session.startAddedTorrents
        self.trashOriginalTorrentFiles = session.trashOriginalTorrentFiles
        self.speedLimitUpEnabled = session.speedLimitUpEnabled
        self.speedLimitDownEnabled = session.speedLimitDownEnabled
        self.speedLimitUp = session.speedLimitUp
        self.speedLimitDown = session.speedLimitDown
        self.seedRatioLimited = session.seedRatioLimited
        self.seedRatioLimit = session.seedRatioLimit
        self.portForfardingEnabled = session.portForfardingEnabled
        self.peerPortRandomOnStart = session.peerPortRandomOnStart
        self.peerPort = session.peerPort
        self.utpEnabled = session.utpEnabled
        self.pexEnabled = session.pexEnabled
        self.lpdEnabled = session.lpdEnabled
        self.dhtEnabled = session.dhtEnabled
        self.peerLimitGlobal = session.peerLimitGlobal
        self.peerLimitPerTorrent = session.peerLimitPerTorrent
        self.encryption = session.encryption
        self.renamePartialFiles = session.renamePartialFiles
        self.blocklistEnabled = session.blocklistEnabled
        self.blocklistUrl = session.blocklistUrl
        self.idleSeedingLimit = session.idleSeedingLimit
        self.idleSeedingLimitEnabled = session.idleSeedingLimitEnabled
        self.altSpeedEnabled = session.altSpeedEnabled
        self.altSpeedDown = session.altSpeedDown
        self.altSpeedUp = session.altSpeedUp
        self.altSpeedTimeEnabled = session.altSpeedTimeEnabled
        self.altSpeedTimeBegin = session.altSpeedTimeBegin
        self.altSpeedTimeEnd = session.altSpeedTimeEnd
        self.altSpeedTimeDay = session.altSpeedTimeDay
        self.cacheSizeMb = session.cacheSizeMb
        self.configDir = session.configDir
        self.rpcVersionMinimum = session.rpcVersionMinimum
        self.blocklistSize = session.blocklistSize
        self.encryptionInt = session.encryptionInt
    }
    
    /*
    private func fillSelectedDays() -> [Bool] {
        var selected = [Bool]()
        for i in 0..<10 {
            selected.insert(self.altSpeedTimeDay == AltDays.day(i),at: i)
        }
        return selected
    }

    

    
    
    open var altLimitSun: Bool {
        get {
            return selectedDays[0]
        }
        set {
            selectedDays[0] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitMon: Bool {
        get {
            return selectedDays[1]
        }
        set {
            selectedDays[1] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitTue: Bool {
        get {
            return selectedDays[2]
        }
        set {
            selectedDays[2] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitWed: Bool {
        get {
            return selectedDays[3]
        }
        set {
            selectedDays[3] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitThu: Bool {
        get {
            return selectedDays[4]
        }
        set {
            selectedDays[4] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitFri: Bool {
        get {
            return selectedDays[5]
        }
        set {
            selectedDays[5] = newValue
            calculateAltDay()
        }
    }

    
    open var altLimitSat: Bool {
        get {
            return selectedDays[6]
        }
        set {
            selectedDays[6] = newValue
            calculateAltDay()
        }
    }
    
    open var altLimitWeekend: Bool {
        get {
            return selectedDays[7]
        }
        set {
            selectedDays[7] = newValue
            calculateAltDay()
        }
    }
    
    open var altLimitWeekday: Bool {
        get {
            return selectedDays[8]
        }
        set {
            selectedDays[8] = newValue
            calculateAltDay()
        }
    }
    
    open var altLimitAll: Bool {
        get {
            return selectedDays[9]
        }
        set {
            selectedDays[9] = newValue
            calculateAltDay()
        }
    }

    
    open var limitTimeBegin: Date? {
        get {

            let c = Calendar.current
            var cp: DateComponents = c.dateComponents([.nanosecond], from: Date())
            cp.hour = altSpeedTimeBegin
            cp.minute = altSpeedTimeBegin

            return c.date(from: cp)
        }
        set(limitTimeBegin) {
            let dt = limitTimeBegin

            let cal = Calendar.current
            var c: DateComponents? = nil
            if(dt != nil){
                c = cal.dateComponents([.hour, .minute], from: dt!)
            }

            altSpeedTimeBegin = c!.hour! * 60 + c!.minute!
        }
    }

    
    open var limitTimeEnd: Date? {
        get {
            let c = Calendar.current
            var cp: DateComponents = c.dateComponents([.nanosecond], from: Date())
            cp.hour = altSpeedTimeEnd
            cp.minute = altSpeedTimeEnd

            return c.date(from: cp)
        }
        set(limitTimeEnd) {

            let dt = limitTimeEnd

            let cal = Calendar.current
            var c: DateComponents? = nil
            if (dt != nil) {
                c = cal.dateComponents([.hour, .minute], from: dt!)
            }

            altSpeedTimeEnd = c!.hour! * 60 + c!.minute!
        }
    }
    */
    
    open var jsonForRPC: JSONObject {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = .prettyPrinted
        var rpcMessage = JSONObject()
        do {
            let data = try encoder.encode(self)
            //print(String(data: data, encoding: .utf8) ?? "")
            rpcMessage = try JSONSerialization.jsonObject(with: data, options: []) as! JSONObject
            //dump(json)
        } catch {
            return JSONObject()
        }
        rpcMessage.removeValue(forKey: JSONKeys.rpc_version)
        rpcMessage.removeValue(forKey: JSONKeys.rpc_version_minimum)
        rpcMessage.removeValue(forKey: JSONKeys.config_dir)
        rpcMessage.removeValue(forKey: JSONKeys.blocklist_size)
        rpcMessage.removeValue(forKey: JSONKeys.version)
        return rpcMessage
    }
    
}
