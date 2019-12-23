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

    private enum CodingKeys: String, CodingKey {
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
        case downloadLimitEnabled = "downloadLimited"
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
        case uploadLimitEnabled = "uploadLimited"
        case uploadRate = "rateUpload"
        case uploadRatio = "uploadRatio"
    }
    
    public var trId: trId = 0
    private var percentDone: Double = 0.00
    public var name: String!
    public var status = TorrentStatus.stopped
    public var dateDone: Date?
    public var errorString: String?
    public var activityDate: Date?
    public var totalSize: Int = 0
    public var downloadedEver: Int = 0
    public var secondsDownloading: TimeInterval = 0
    public var secondsSeeding: TimeInterval = 0
    public var uploadRate: Int = 0
    public var downloadRate: Int = 0
    public var peersConnected: Int = 0
    public var peersSendingToUs: Int = 0
    public var peersGettingFromUs: Int = 0
    public var uploadedEver: Int = 0
    public var uploadRatio: Double = 0.0
    public var hashString: String = ""
    public var piecesCount: Int = 0
    public var pieceSize: Int = 0
    public var comment: String = ""
    public var downloadDir: String = ""
    public var errorNumber: Int = 0
    public var creator: String = ""
    public var dateCreated: Date?
    public var dateAdded: Date?
    public var haveValid: Double = 0.0
    public var recheckProgress: Double = 0.0
    public var bandwidthPriority: Int = 0
    public var bandwidthPriorityString: String = ""
    public var honorsSessionLimits: Bool = false
    public var peerLimit: Int = 0
    public var uploadLimitEnabled: Bool = false
    public var uploadLimit: Int = 0
    public var downloadLimitEnabled: Bool = false
    public var downloadLimit: Int = 0
    public var seedIdleMode: Int = 0
    public var seedIdleLimit: Int = 0
    public var seedRatioMode: Int = 0
    public var seedRatioLimit: Double = 0
    public var queuePosition: Int = 0
    public var eta: Int = 0
    public var haveUnchecked: Int = 0
//    public var piecesBitmap: NSData!
    
    
    public var isError: Bool {
        return errorString != nil && errorString!.count > 0
    }
    
    public var isDownloading: Bool {
        
        return status == .download
    }
    
    public var isWaiting:Bool {
        return status == .downloadWait || status == .seedWait
    }
    
    public var isChecking: Bool {
        return status == .check
    }
    
    public var isSeeding: Bool {
        return status == .seed
    }
    
    public var isStopped: Bool {
        return status == .stopped && percentDone < 1
    }
    
    public  var isFinished: Bool {
        return status == .stopped && percentDone == 1
    }
    
    public var dateLastActivityString:String {
        return activityDate != Date(timeIntervalSince1970: 0) ? formatDate(activityDate)! : ""
    }
    
    public var dateAddedString:String {
        return dateAdded != Date(timeIntervalSince1970: 0) ? formatDate(dateAdded)! : ""
    }
    
    public var dateCreatedString:String {
        return dateCreated != Date(timeIntervalSince1970: 0) ? formatDate(dateCreated)! : ""
    }
    
    public var dateDoneString: String {
        return dateDone != Date(timeIntervalSince1970: 0) ? formatDate(dateDone)! : ""
    }
    
    public var downloadedEverString: String {
        return formatByteCount(downloadedEver)
    }
    
    public var downloadedSize:Double {
        return Double(totalSize) * percentDone
    }
    
    public var downloadedSizeString:String {
        return formatByteCount(Int(downloadedSize))
    }
    
    public var downloadingTimeString:String {
        return formatHoursMinutes(secondsDownloading)
    }
    
    public var etaTimeString:String {
        return formatHoursMinutes(TimeInterval(eta)) == "" ? NSLocalizedString(" ", comment: "ETA time string") : formatHoursMinutes(TimeInterval(eta))
    }
    
    public var haveUncheckedString:String {
        return formatByteCount(haveUnchecked)
    }
    
    public var haveValidString: String {
        return formatByteCount(Int(haveValid))
    }
    
    public var percentsDoneString:String {
        if status == .check {
            return String(format: "%.2f%%", recheckProgress * 100)
        }
        return String(format: "%.f%%", percentDone * 100)
    }
    
    public var percentsDone: Double {
        if status == .check {
            return recheckProgress
        }
        return percentDone
    }
    
    public var pieceSizeString:String {
        return formatByteCount(pieceSize)
    }
    
    public var recheckProgressString:String {
        return String(format: "%03.2f%%", recheckProgress * 100)
    }
    
    public var seedingTimeString: String {
        return formatHoursMinutes(TimeInterval(secondsSeeding ))
    }
    
    public var uploadedEverString: String {
        return formatByteCount(uploadedEver)
    }
    
    public var statusString: String {
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
        if isError {
            statusStr = NSLocalizedString("trError", comment: "")
        }
        return statusStr
    }
    
    public var downloadRateString: String {
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
    
    public var uploadRateString: String {
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
    
    public var totalSizeString: String {
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
    
    public var jsonObject: JSONObject {
        var rpcMessage = JSONObject()
        rpcMessage[JSONKeys.bandwidthPriority] = bandwidthPriority
        rpcMessage[JSONKeys.downloadLimit] = downloadLimit
        rpcMessage[JSONKeys.downloadLimited] = downloadLimitEnabled
        rpcMessage[JSONKeys.honorsSessionLimits] = honorsSessionLimits
        rpcMessage[JSONKeys.peer_limit] = peerLimit
        rpcMessage[JSONKeys.queuePosition] = queuePosition
        rpcMessage[JSONKeys.seedIdleLimit] = seedIdleLimit
        rpcMessage[JSONKeys.seedIdleMode] = seedIdleMode
        rpcMessage[JSONKeys.seedRatioLimit] = seedRatioLimit
        rpcMessage[JSONKeys.seedRatioMode] = seedRatioMode
        rpcMessage[JSONKeys.uploadLimit] = uploadLimit
        rpcMessage[JSONKeys.uploadLimited] = uploadLimitEnabled
        return rpcMessage
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


