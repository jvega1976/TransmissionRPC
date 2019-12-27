//
//  Torrent.swift
//  TransmissionRPC
//
//  Created by Johnny A. Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//
//  Torrent info class

import Foundation
#if os(iOS)
import MobileCoreServices
#endif

// MARK: - Typealias
public typealias trId = Int

// MARK: - Torrent class definition
@objcMembers open class Torrent: NSObject, Codable  {

     private enum CodingKeys: String, CodingKey, CaseIterable {
        case activityDate = "activityDate"
        case bandwidthPriority = "bandwidthPriority"
        case comment = "comment"
        case creator = "creator"
        case dateAdded = "addedDate"
        case dateCreated = "dateCreated"
        case dateDone = "doneDate"
        case downloadDir = "downloadDir"
        case downloadedEver = "downloadedEver"
        case downloadLimit = "downloadLimit"
        case downloadLimited = "downloadLimited"
        case downloadRate = "rateDownload"
        case errorNumber = "error"
        case errorString = "errorString"
        case eta = "eta"
        case hashString = "hashString"
        case haveUnchecked = "haveUnchecked"
        case haveValid = "haveValid"
        case honorsSessionLimits = "honorsSessionLimits"
        case name = "name"
        case peerLimit = "peer-limit"
        case peersConnected = "peersConnected"
        case peersGettingFromUs = "peersGettingFromUs"
        case peersSendingToUs = "peersSendingToUs"
        case percentDone = "percentDone"
        case piecesCount = "pieceCount"
        case pieceSize = "pieceSize"
        case queuePosition = "queuePosition"
        case recheckProgress = "recheckProgress"
        case seedIdleLimit = "seedIdleLimit"
        case seedIdleMode = "seedIdleMode"
        case secondsDownloading = "secondsDownloading"
        case secondsSeeding = "secondsSeeding"
        case seedRatioLimit = "seedRatioLimit"
        case seedRatioMode = "seedRatioMode"
        case status = "status"
        case totalSize = "totalSize"
        case trId = "id"
        case uploadedEver = "uploadedEver"
        case uploadLimit = "uploadLimit"
        case uploadLimited = "uploadLimited"
        case uploadRate = "rateUpload"
        case uploadRatio = "uploadRatio"
    }
    
    @objc dynamic public var trId: trId = 0
    @objc dynamic private var percentDone: Double = 0.00
    @objc dynamic public var name: String!
    @objc dynamic public var status = TorrentStatus.stopped
    @objc dynamic public var dateDone: Date?
    @objc dynamic public var errorString: String?
    @objc dynamic public var activityDate: Date?
    @objc dynamic public var totalSize: Int = 0
    @objc dynamic public var downloadedEver: Int = 0
    @objc dynamic public var secondsDownloading: TimeInterval = 0
    @objc dynamic public var secondsSeeding: TimeInterval = 0
    @objc dynamic public var uploadRate: Int = 0
    @objc dynamic public var downloadRate: Int = 0
    @objc dynamic public var peersConnected: Int = 0
    @objc dynamic public var peersSendingToUs: Int = 0
    @objc dynamic public var peersGettingFromUs: Int = 0
    @objc dynamic public var uploadedEver: Int = 0
    @objc dynamic public var uploadRatio: Double = 0.0
    @objc dynamic public var hashString: String = ""
    @objc dynamic public var piecesCount: Int = 0
    @objc dynamic public var pieceSize: Int = 0
    @objc dynamic public var comment: String = ""
    @objc dynamic public var downloadDir: String = ""
    @objc dynamic public var errorNumber: Int = 0
    @objc dynamic public var creator: String = ""
    @objc dynamic public var dateCreated: Date?
    @objc dynamic public var dateAdded: Date?
    @objc dynamic public var haveValid: Double = 0.0
    @objc dynamic public var recheckProgress: Double = 0.0
    @objc dynamic public var bandwidthPriority: Int = 0
    @objc dynamic public var honorsSessionLimits: Bool = false
    @objc dynamic public var peerLimit: Int = 0
    @objc dynamic public var uploadLimited: Bool = false
    @objc dynamic public var uploadLimit: Int = 0
    @objc dynamic public var downloadLimited: Bool = false
    @objc dynamic public var downloadLimit: Int = 0
    @objc dynamic public var seedIdleMode: Int = 0
    @objc dynamic public var seedIdleLimit: Int = 0
    @objc dynamic public var seedRatioMode: Int = 0
    @objc dynamic public var seedRatioLimit: Double = 0
    @objc dynamic public var queuePosition: Int = 0
    @objc dynamic public var eta: Int = 0
    @objc dynamic public var haveUnchecked: Int = 0
//    public var piecesBitmap: NSData!
    
    
    public class func propertyStringName(stringValue value: String) -> String? {
        return CodingKeys.allCases.first(where: {key in
            return key.rawValue.camelCased  == value})?.rawValue
    }
    
    
    
    @objc dynamic public var isError: Bool {
        return errorString != nil && errorString!.count > 0
    }
    
    
    @objc dynamic public var isDownloading: Bool {
        
        return status == .download
    }
    
    @objc dynamic public var isWaiting: Bool {
        return status == .downloadWait || status == .seedWait
    }
    
    @objc dynamic public var isChecking: Bool {
        return status == .check
    }
    
    @objc dynamic public var isSeeding: Bool {
        return status == .seed
    }
    
    @objc dynamic public var isStopped: Bool {
        return status == .stopped && percentDone < 1
    }
    
    public  var isFinished: Bool {
        return status == .stopped && percentDone == 1
    }
    
    @objc dynamic public var dateLastActivityString:String {
        return activityDate != Date(timeIntervalSince1970: 0) ? formatDate(activityDate)! : ""
    }
    
    @objc dynamic public var dateAddedString:String {
        return dateAdded != Date(timeIntervalSince1970: 0) ? formatDate(dateAdded)! : ""
    }
    
    @objc dynamic public var dateCreatedString:String {
        return dateCreated != Date(timeIntervalSince1970: 0) ? formatDate(dateCreated)! : ""
    }
    
    @objc dynamic public var dateDoneString: String {
        return dateDone != Date(timeIntervalSince1970: 0) ? formatDate(dateDone)! : ""
    }
    
    @objc dynamic public var downloadedEverString: String {
        return formatByteCount(downloadedEver)
    }
    
    @objc dynamic public var downloadedSize:Double {
        return Double(totalSize) * percentDone
    }
    
    @objc dynamic public var downloadedSizeString:String {
        return formatByteCount(Int(downloadedSize))
    }
    
    @objc dynamic public var downloadingTimeString:String {
        return formatHoursMinutes(secondsDownloading)
    }
    
    @objc dynamic public var etaTimeString:String {
        return formatHoursMinutes(TimeInterval(eta)) == "" ? NSLocalizedString(" ", comment: "ETA time string") : formatHoursMinutes(TimeInterval(eta))
    }
    
    @objc dynamic public var haveUncheckedString:String {
        return formatByteCount(haveUnchecked)
    }
    
    @objc dynamic public var haveValidString: String {
        return formatByteCount(Int(haveValid))
    }
    
    @objc dynamic public var percentsDoneString:String {
        if status == .check {
            return String(format: "%.2f%%", recheckProgress * 100)
        }
        return String(format: "%.f%%", percentDone * 100)
    }
    
    class func keyPathsForValuesAffectingPercentsDoneString() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["percentDone"])
    }
    
    @objc dynamic public var percentsDone: Double {
        if status == .check {
            return recheckProgress
        }
        return percentDone
    }
    
    class func keyPathsForValuesAffectingPercentsDone() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["percentDone","status"])
    }
    
    @objc dynamic public var pieceSizeString:String {
        return formatByteCount(pieceSize)
    }
    
    @objc dynamic public var recheckProgressString:String {
        return String(format: "%03.2f%%", recheckProgress * 100)
    }
    
    @objc dynamic public var seedingTimeString: String {
        return formatHoursMinutes(TimeInterval(secondsSeeding ))
    }
    
    @objc dynamic public var uploadedEverString: String {
        return formatByteCount(uploadedEver)
    }
    
    @objc dynamic public var bandwidthPriorityString: String {
        switch bandwidthPriority {
            case -1: return "Low"
            case 0: return "Normal"
            case 1: return "High"
            default: return "Unknown"
        }
    }
    
    @objc dynamic public var statusString: String {
        var statusStr = "Unknown"
        switch self.status {
            case .download:
                statusStr = NSLocalizedString("trDownloading", comment: "")
            case .downloadWait:
                statusStr = NSLocalizedString("trWaiting", comment: "")
            case .check:
                statusStr = NSLocalizedString("trWaitingCheck", comment: "")
            case .checkWait:
                statusStr = NSLocalizedString("trWaitingCheck", comment: "")
            case .seedWait:
                statusStr = NSLocalizedString("trWaitingSeed", comment: "")
             case .seed:
                statusStr = NSLocalizedString("trSeeding", comment: "")
             case .stopped:
                statusStr = NSLocalizedString("trStopped", comment: "")
        }
        return statusStr
    }
    
    @objc dynamic public var downloadRateString: String {
        var downStr: String! = ""
        if status == .download {
            downStr = NSLocalizedString("↓DL: \(formatByteRate(downloadRate))", comment: "")
        } else if status == .downloadWait {
            downStr = NSLocalizedString("↓DL: \(formatByteRate(downloadRate))", comment: "")
        } else if status == .stopped {
            downStr = NSLocalizedString("no activity", comment: "")
        }
        return downStr
    }
    
    @objc dynamic public var uploadRateString: String {
        var uplStr: String! = ""
        if status == .download {
            uplStr = NSLocalizedString("↑UL: \(formatByteRate(uploadRate))", comment: "")
        } else if status == .downloadWait {
            uplStr = NSLocalizedString("↑UL: \(formatByteRate(uploadRate))", comment: "")
        } else if status == .seed {
            uplStr = NSLocalizedString("↑UL: \(formatByteRate(uploadRate))", comment: "")
        }
        return uplStr
    }
    
    @objc dynamic public var speedString: String {
        if isSeeding {
            return uploadRateString
        }
        else if isFinished || isStopped {
            return downloadRateString
        } else {
            return String(format: "%@ / %@", downloadRateString, uploadRateString)
        }
    }
    
    @objc dynamic public var ratioString: String {
        return String(format: "%02.2f", uploadRatio)
    }
    
    @objc dynamic public var sizeString: String {
        return formatByteCount(totalSize)
    }
    
    @objc dynamic public var totalSizeString: String {
        var sizeStr: String! = ""
        if status == .download {
            sizeStr = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), downloadedEverString, formatByteCount(totalSize), uploadedEverString, uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else if status == .downloadWait {
            sizeStr = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), downloadedEverString, formatByteCount(totalSize), uploadedEverString, uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else if status == .seed {
            sizeStr = String(format: NSLocalizedString("%@, uploaded %@ (Ratio %0.2f)", comment: ""), formatByteCount(totalSize), uploadedEverString, uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else if status == .stopped {
            sizeStr = String(format: NSLocalizedString("%@, uploaded %@ (Ratio %0.2f)", comment: ""), downloadedSizeString, uploadedEverString, uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else {
            sizeStr = ""
        }
        if isError {
            sizeStr = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), downloadedSizeString, formatByteCount(totalSize), uploadedEverString, uploadRatio < 0.0 ? 0.0 : uploadRatio)
        }
        return sizeStr
    }
    
    class func keyPathsForValuesAffectingTotalSizeString() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["status","downloadedEver","totalSize","uploadedEver","uploadRatio"])
    }
    
    @objc dynamic public var jsonObject: JSONObject {
        get {
            var rpcMessage = JSONObject()
            rpcMessage[JSONKeys.bandwidthPriority] = bandwidthPriority
            rpcMessage[JSONKeys.downloadLimit] = downloadLimit
            rpcMessage[JSONKeys.downloadLimited] = downloadLimited
            rpcMessage[JSONKeys.honorsSessionLimits] = honorsSessionLimits
            rpcMessage[JSONKeys.peer_limit] = peerLimit
            rpcMessage[JSONKeys.queuePosition] = queuePosition
            rpcMessage[JSONKeys.seedIdleLimit] = seedIdleLimit
            rpcMessage[JSONKeys.seedIdleMode] = seedIdleMode
            rpcMessage[JSONKeys.seedRatioLimit] = seedRatioLimit
            rpcMessage[JSONKeys.seedRatioMode] = seedRatioMode
            rpcMessage[JSONKeys.uploadLimit] = uploadLimit
            rpcMessage[JSONKeys.uploadLimited] = uploadLimited
            return rpcMessage
        }
    }

}

// MARK: - Comparable Protocol adoption
@objc extension Torrent: Comparable {
    
    public override var hash: Int {
        return self.trId
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let trInfo = object as? Torrent else { return false}
        return trInfo.trId == self.trId
    }
    
    public static func < (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.queuePosition < rhs.queuePosition
    }
    
    public static func <= (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.queuePosition <= rhs.queuePosition
    }
    
    public static func > (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.queuePosition > rhs.queuePosition
    }
    
    public static func >= (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.queuePosition >= rhs.queuePosition
    }
    
    public static func == (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.trId == rhs.trId
    }
    
    public static func != (lhs: Torrent, rhs: Torrent) -> Bool {
        return lhs.trId != rhs.trId
    }
}


// MARK: - NSItemProviderWriting and NSItemProviderReading Protocols adoption

@objc extension Torrent: NSItemProviderWriting, NSItemProviderReading {
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeUTF8PlainText) as String]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let progress = Progress(totalUnitCount: 100)
        do {
            //Here the object is encoded to a JSON data object and sent to the completion handler
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
    }
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeUTF8PlainText) as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        let decoder = JSONDecoder()
        do {
            //Here we decode the object back to it's class representation and return it
            let trInfo = try decoder.decode(self, from: data)
            return trInfo
        } catch {
            throw error
        }
    }
}


