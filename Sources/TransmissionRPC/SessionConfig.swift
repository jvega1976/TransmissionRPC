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
    
    dynamic public var intVal: Int {
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

public struct AltDays
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


//MARK: - SessionConfig struct definition
@objcMembers open class SessionConfig: NSObject, Codable {
    
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
    
    @objc dynamic public var version = ""
    @objc dynamic public var rpcVersion = 0
    @objc dynamic public var downloadDir = ""
    @objc dynamic public var incompletedDirEnabled = false
    @objc dynamic public var incompletedDir = ""
    @objc dynamic public var scriptTorrentDoneEnabled = false
    @objc dynamic public var scriptTorrentDoneFilename = ""
    @objc dynamic public var downloadQueueEnabled = false
    @objc dynamic public var downloadQueueSize = 0
    @objc dynamic public var seedQueueEnabled = false
    @objc dynamic public var seedQueueSize = 0
    @objc dynamic public var queueStalledEnabled = false
    @objc dynamic public var queueStalledMinutes = 0
    @objc dynamic public var startAddedTorrents = false
    @objc dynamic public var trashOriginalTorrentFiles = false
    @objc dynamic public var speedLimitUpEnabled = false
    @objc dynamic public var speedLimitDownEnabled = false
    @objc dynamic public var speedLimitUp = 0
    @objc dynamic public var speedLimitDown = 0
    @objc dynamic public var seedRatioLimited = false
    @objc dynamic public var seedRatioLimit = 0.0
    @objc dynamic public var portForfardingEnabled = false
    @objc dynamic public var peerPortRandomOnStart = false
    @objc dynamic public var peerPort = 0
    @objc dynamic public var utpEnabled = false
    @objc dynamic public var pexEnabled = false
    @objc dynamic public var lpdEnabled = false
    @objc dynamic public var dhtEnabled = false
    @objc dynamic public var peerLimitGlobal  = 0
    @objc dynamic public var peerLimitPerTorrent  = 0
    public var encryption: Encryption = .preferred
    @objc dynamic public var renamePartialFiles = false
    @objc dynamic public var blocklistEnabled = false
    @objc dynamic public var blocklistUrl = ""
    @objc dynamic public var idleSeedingLimit = 0
    @objc dynamic public var idleSeedingLimitEnabled = false
    @objc dynamic public var altSpeedEnabled = false
    @objc dynamic public var altSpeedDown = 0
    @objc dynamic public var altSpeedUp = 0
    @objc dynamic public var altSpeedTimeEnabled = false
    @objc dynamic public var altSpeedTimeBegin = 0
    @objc dynamic public var altSpeedTimeEnd = 0
    @objc dynamic public var altSpeedTimeDay: Int = 0
    @objc dynamic public var cacheSizeMb = 0
    @objc dynamic public var configDir = ""
    @objc dynamic public var rpcVersionMinimum = 0
    @objc dynamic public var blocklistSize = 0
    private lazy var selectedDays = fillSelectedDays()
    private var firstTime: Bool = true
    
    public class func propertyStringName(stringValue value: String) -> String? {
        return CodingKeys.allCases.first(where: {key in
            return key.rawValue.camelCased == value})?.rawValue
    }
   
    
    private func fillSelectedDays() -> [Bool] {
        var selected = [Bool]()
        for i in 0..<10 {
            selected.insert(self.altSpeedTimeDay == AltDays.day(i),at: i)
        }
        return selected
    }

    
    private func calculateAltDay() {
        self.altSpeedTimeDay = AltDays.day(selectedDays.firstIndex(of: true) ?? 0)
    }
    
    
    @objc dynamic open var encryptionId: Int {
        set(encript) {
            encryption = Encryption(encript)
        }
        get {
            encryption.intVal
        }
    }
    
    @objc dynamic open var altLimitSun: Bool {
        get {
            return selectedDays[0]
        }
        set {
            selectedDays[0] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitMon: Bool {
        get {
            return selectedDays[1]
        }
        set {
            selectedDays[1] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitTue: Bool {
        get {
            return selectedDays[2]
        }
        set {
            selectedDays[2] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitWed: Bool {
        get {
            return selectedDays[3]
        }
        set {
            selectedDays[3] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitThu: Bool {
        get {
            return selectedDays[4]
        }
        set {
            selectedDays[4] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitFri: Bool {
        get {
            return selectedDays[5]
        }
        set {
            selectedDays[5] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var altLimitSat: Bool {
        get {
            return selectedDays[6]
        }
        set {
            selectedDays[6] = newValue
            calculateAltDay()
        }
    }
    
    @objc dynamic open var altLimitWeekend: Bool {
        get {
            return selectedDays[7]
        }
        set {
            selectedDays[7] = newValue
            calculateAltDay()
        }
    }
    
    @objc dynamic open var altLimitWeekday: Bool {
        get {
            return selectedDays[8]
        }
        set {
            selectedDays[8] = newValue
            calculateAltDay()
        }
    }
    
    @objc dynamic open var altLimitAll: Bool {
        get {
            return selectedDays[9]
        }
        set {
            selectedDays[9] = newValue
            calculateAltDay()
        }
    }

    
    @objc dynamic open var limitTimeBegin: Date? {
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

    
    @objc dynamic open var limitTimeEnd: Date? {
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
    
    
    @objc dynamic open var jsonForRPC: JSONObject {
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
    
}
