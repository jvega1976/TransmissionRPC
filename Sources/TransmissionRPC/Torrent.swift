//
//  Torrent.swift
//  TransmissionRPC
//
//  Created by Johnny A. Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//
//  Torrent info class

import Foundation
import Combine

#if os(iOS)
import MobileCoreServices
#endif

// MARK: - Typealias
public typealias trId = Int

// MARK: - Torrent class definition
@objc(Torrent)
open class Torrent: NSObject, Codable, ObservableObject, Identifiable  {

    // MARK: - Class CodingKeys
     private enum CodingKeys: String, CodingKey, CaseIterable {
        case activityDate = "activityDate"
        case editDate = "editDate"
        case startDate = "startDate"
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
    
    // MARK: - Class Properties
    @Published public var trId: trId = 0
    @Published public var percentDone: Double = 0.00
    @Published public var name: String!
    @Published public var status = TorrentStatus.stopped
    @Published public var dateDone: Date?
    @Published public var errorString: String = ""
    @Published public var activityDate: Date?
    @Published public var editDate: Date?
    @Published public var startDate: Date?
    @Published public var totalSize: Int = 0
    @Published public var downloadedEver: Int = 0
    @Published public var secondsDownloading: TimeInterval = 0
    @Published public var secondsSeeding: TimeInterval = 0
    @Published public var uploadRate: Int = 0
    @Published public var downloadRate: Int = 0
    @Published public var peersConnected: Int = 0
    @Published public var peersSendingToUs: Int = 0
    @Published public var peersGettingFromUs: Int = 0
    @Published public var uploadedEver: Int = 0
    @Published public var uploadRatio: Double = 0.0
    @Published public var hashString: String = ""
    @Published public var piecesCount: Int = 0
    @Published public var pieceSize: Int = 0
    @Published public var comment: String = ""
    @Published public var downloadDir: String = ""
    @Published public var errorNumber: Int = 0
    @Published public var creator: String = ""
    @Published public var dateCreated: Date?
    @Published public var dateAdded: Date!
    @Published public var haveValid: Double = 0.0
    @Published public var recheckProgress: Double = 0.0
    @Published public var bandwidthPriority: Int = 0
    @Published public var honorsSessionLimits: Bool = false
    @Published public var peerLimit: Int = 0
    @Published public var uploadLimited: Bool = false
    @Published public var uploadLimit: Int = 0
    @Published public var downloadLimited: Bool = false
    @Published public var downloadLimit: Int = 0
    @Published public var seedIdleMode: Int = 0
    @Published public var seedIdleLimit: Int = 0
    @Published public var seedRatioMode: Int = 0
    @Published public var seedRatioLimit: Double = 0
    @Published public var queuePosition: Int = 0
    @Published public var eta: Int = 0
    @Published public var haveUnchecked: Int = 0
    
    // MARK: - Class computed properties

    @Published public private (set) var isError: Bool = false
    @Published public private (set) var isDownloading: Bool = false
    @Published public private (set) var isWaiting: Bool = false
    @Published public private (set) var isChecking: Bool = false
    @Published public private (set) var isSeeding: Bool = false
    @Published public private (set) var isStopped: Bool = false
    @Published public private (set) var isFinished: Bool = false
    @Published public private (set) var downloadedSize: Double = 0.0
    @Published public private (set) var etaTimeString: String = ""
    @Published public private (set) var percentsDone: Double = 0.0
    @Published public private (set) var downloadRateString: String = ""
    @Published public private (set) var uploadRateString: String = ""
    @Published public private (set) var speedString: String = ""
    @Published public private (set) var totalSizeString: String = ""
    @Published public private (set) var detailStatus: String = ""
    @Published public private (set) var peersDetail: String = ""
    @Published public private (set) var statusString: String = ""

    
    public var id: Int  {
        return self.trId
    }
    
    /// Decoder Initializer
    public required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trId = try values.decode(Int.self, forKey: .trId)
        status = (try? values.decode(TorrentStatus.self, forKey: .status)) ?? .unknown
        percentDone = (try? values.decode(Double.self, forKey: .percentDone)) ?? 0.0
        name = (try? values.decode(String.self, forKey: .name)) ?? ""
        dateDone = try? values.decode(Date.self, forKey: .dateDone)
        errorString = (try? values.decode(String.self, forKey: .errorString)) ?? ""
        activityDate = try? values.decode(Date.self, forKey: .activityDate)
        editDate = try? values.decode(Date.self, forKey: .editDate)
        startDate = try? values.decode(Date.self, forKey: .startDate)
        totalSize = (try? values.decode(Int.self, forKey: .totalSize)) ?? 0
        downloadedEver = (try? values.decode(Int.self, forKey: .downloadedEver)) ?? 0
        secondsDownloading = (try? values.decode(TimeInterval.self, forKey: .secondsDownloading)) ?? 0
        secondsSeeding = (try? values.decode(TimeInterval.self, forKey: .secondsSeeding)) ?? 0
        uploadRate = (try? values.decode(Int.self, forKey: .uploadRate)) ?? 0
        downloadRate = (try? values.decode(Int.self, forKey: .downloadRate)) ?? 0
        peersConnected = (try? values.decode(Int.self, forKey: .peersConnected)) ?? 0
        peersSendingToUs = (try? values.decode(Int.self, forKey: .peersSendingToUs)) ?? 0
        peersGettingFromUs = (try? values.decode(Int.self, forKey: .peersGettingFromUs)) ?? 0
        uploadedEver = (try? values.decode(Int.self, forKey: .uploadedEver)) ?? 0
        uploadRatio = (try? values.decode(Double.self, forKey: .uploadRatio)) ?? 0.0
        hashString = (try? values.decode(String.self, forKey: .hashString)) ?? ""
        piecesCount = (try? values.decode(Int.self, forKey: .piecesCount)) ?? 0
        pieceSize = (try? values.decode(Int.self, forKey: .pieceSize)) ?? 0
        comment = (try? values.decode(String.self, forKey: .comment)) ?? ""
        downloadDir = (try? values.decode(String.self, forKey: .downloadDir)) ?? ""
        errorNumber = (try? values.decode(Int.self, forKey: .errorNumber)) ?? 0
        creator = (try? values.decode(String.self, forKey: .creator)) ?? ""
        dateCreated = try? values.decode(Date?.self, forKey: .dateCreated)
        dateAdded = (try? values.decode(Date?.self, forKey: .dateAdded)) ?? Date(timeIntervalSince1970: 0)
        haveValid = (try? values.decode(Double.self, forKey: .haveValid)) ?? 0
        recheckProgress = (try? values.decode(Double.self, forKey: .recheckProgress)) ?? 0
        bandwidthPriority = (try? values.decode(Int.self, forKey: .bandwidthPriority)) ?? 0
        honorsSessionLimits = (try? values.decode(Bool.self, forKey: .honorsSessionLimits)) ?? false
        peerLimit = (try? values.decode(Int.self, forKey: .peerLimit)) ?? 0
        uploadLimited = (try? values.decode(Bool.self, forKey: .uploadLimited)) ?? false
        uploadLimit = (try? values.decode(Int.self, forKey: .uploadLimit)) ?? 0
        downloadLimited = (try? values.decode(Bool.self, forKey: .downloadLimited)) ?? false
        downloadLimit = (try? values.decode(Int.self, forKey: .downloadLimit)) ?? 0
        seedIdleMode = (try? values.decode(Int.self, forKey: .seedIdleMode)) ?? 0
        seedIdleLimit = (try? values.decode(Int.self, forKey: .seedIdleLimit)) ?? 0
        seedRatioMode = (try? values.decode(Int.self, forKey: .seedRatioMode)) ?? 0
        seedRatioLimit = (try? values.decode(Double.self, forKey: .seedRatioLimit)) ?? 0.0
        queuePosition = (try? values.decode(Int.self, forKey: .queuePosition)) ?? 0
        eta = (try? values.decode(Int.self, forKey: .eta)) ?? 0
        haveUnchecked = (try? values.decode(Int.self, forKey: .haveUnchecked)) ?? 0

        CommonInit()
    
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trId, forKey: .trId)
        try container.encode(percentDone, forKey: .percentDone)
        try container.encode(name, forKey: .name)
        try container.encode(dateDone, forKey: .dateDone)
        try container.encode(errorString, forKey: .errorString)
        try container.encode(activityDate, forKey: .activityDate)
        try container.encode(editDate, forKey: .editDate)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(totalSize, forKey: .totalSize)
        try container.encode(downloadedEver, forKey: .downloadedEver)
        try container.encode(secondsDownloading, forKey: .secondsDownloading)
        try container.encode(secondsSeeding, forKey: .secondsSeeding)
        try container.encode(uploadRate, forKey: .uploadRate)
        try container.encode(downloadRate, forKey: .downloadRate)
        try container.encode(peersConnected, forKey: .peersConnected)
        try container.encode(peersSendingToUs, forKey: .peersSendingToUs)
        try container.encode(peersGettingFromUs, forKey: .peersGettingFromUs)
        try container.encode(uploadedEver, forKey: .uploadedEver)
        try container.encode(uploadRatio, forKey: .uploadRatio)
        try container.encode(hashString, forKey: .hashString)
        try container.encode(piecesCount, forKey: .piecesCount)
        try container.encode(pieceSize, forKey: .pieceSize)
        try container.encode(comment, forKey: .comment)
        try container.encode(downloadDir, forKey: .downloadDir)
        try container.encode(errorNumber, forKey: .errorNumber)
        try container.encode(creator, forKey: .creator)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(haveValid, forKey: .haveValid)
        try container.encode(recheckProgress, forKey: .recheckProgress)
        try container.encode(bandwidthPriority, forKey: .bandwidthPriority)
        try container.encode(honorsSessionLimits, forKey: .honorsSessionLimits)
        try container.encode(peerLimit, forKey: .peerLimit)
        try container.encode(uploadLimited, forKey: .uploadLimited)
        try container.encode(uploadLimit, forKey: .uploadLimit)
        try container.encode(downloadLimited, forKey: .downloadLimited)
        try container.encode(downloadLimit, forKey: .downloadLimit)
        try container.encode(seedIdleMode, forKey: .seedIdleMode)
        try container.encode(seedIdleLimit, forKey: .seedIdleLimit)
        try container.encode(seedRatioMode, forKey: .seedRatioMode)
        try container.encode(seedRatioLimit, forKey: .seedRatioLimit)
        try container.encode(queuePosition, forKey: .queuePosition)
        try container.encode(eta, forKey: .eta)
        try container.encode(haveUnchecked, forKey: .haveUnchecked)
        try container.encode(status, forKey: .status)
    }
    
    
    /// required Initializer
    public override init() {
        super.init()
        trId = Int.random(in: 100000...999999)
        queuePosition = Int.random(in: 100000...999999)
        name = "Torrent"
        CommonInit()
    }
    
    public func CommonInit()->Void {
        self.isError = self.errorString.count > 0 && self.errorNumber != 0
        self.isDownloading = self.status == .download
        self.isWaiting = self.status == .downloadWait || self.status == .seedWait || self.status == .checkWait
        self.isChecking = self.status == .check
        self.isSeeding = self.status == .seed
        self.isStopped = self.status == .stopped && self.percentDone < 1
        self.isFinished = self.status == .stopped && self.percentDone >= 1
        self.downloadedSize = Double(self.totalSize) * self.percentDone
        self.etaTimeString = DateFormatter.formatHoursMinutes(TimeInterval(self.eta)) == "" ? NSLocalizedString("...", comment: "ETA time string") : DateFormatter.formatHoursMinutes(TimeInterval(self.eta))
        self.percentsDone = self.status == .check ? self.recheckProgress : self.percentDone
        
        if self.status == .download {
            self.downloadRateString = NSLocalizedString("↓DL: \(ByteCountFormatter.formatByteRate(self.downloadRate))", comment: "")
        } else if self.status == .downloadWait {
            self.downloadRateString = NSLocalizedString("↓DL: \(ByteCountFormatter.formatByteRate(self.downloadRate))", comment: "")
        } else if status == .stopped {
            self.downloadRateString = NSLocalizedString("no activity", comment: "")
        } else {
            self.downloadRateString = ""
        }
        
        if self.status == .download {
            self.uploadRateString = NSLocalizedString("↑UL: \(ByteCountFormatter.formatByteRate(uploadRate))", comment: "")
        } else if status == .downloadWait {
            self.uploadRateString = NSLocalizedString("↑UL: \(ByteCountFormatter.formatByteRate(uploadRate))", comment: "")
        } else if status == .seed {
           self.uploadRateString = NSLocalizedString("↑UL: \(ByteCountFormatter.formatByteRate(uploadRate))", comment: "")
        } else {
            self.uploadRateString = ""
        }
        
        if self.isSeeding {
            self.speedString = self.uploadRateString
        } else if self.isFinished || self.isStopped {
            self.speedString = self.downloadRateString
        } else {
            self.speedString = "\(self.downloadRateString) / \(self.uploadRateString)"
        }
        
        
        if self.status == .download {
            self.totalSizeString = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), ByteCountFormatter.formatByteCount(downloadedEver),  ByteCountFormatter.formatByteCount(self.totalSize),ByteCountFormatter.formatByteCount(self.uploadedEver), self.uploadRatio < 0.0 ? 0.0 : self.uploadRatio)
        } else if status == .downloadWait {
            self.totalSizeString = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), ByteCountFormatter.formatByteCount(downloadedEver), ByteCountFormatter.formatByteCount(totalSize), ByteCountFormatter.formatByteCount(self.uploadedEver), uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else if status == .seed {
            self.totalSizeString = String(format: NSLocalizedString("%@, uploaded %@ (Ratio %0.2f)", comment: ""), ByteCountFormatter.formatByteCount(totalSize), ByteCountFormatter.formatByteCount(self.uploadedEver), uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else if status == .stopped {
            self.totalSizeString = String(format: NSLocalizedString("%@, uploaded %@ (Ratio %0.2f)", comment: ""), ByteCountFormatter.formatByteCount(Int(self.downloadedSize)), ByteCountFormatter.formatByteCount(self.uploadedEver), uploadRatio < 0.0 ? 0.0 : uploadRatio)
        } else {
            self.totalSizeString = ""
        }
        
        
        if isError {
            self.totalSizeString = String(format: NSLocalizedString("%@ of %@, uploaded %@ (Ratio %0.2f)", comment: ""), ByteCountFormatter.formatByteCount(Int(self.downloadedSize)), ByteCountFormatter.formatByteCount(totalSize), ByteCountFormatter.formatByteCount(self.uploadedEver), self.uploadRatio < 0.0 ? 0.0 : self.uploadRatio)
        }
        
        if isError {
            self.detailStatus = NSLocalizedString("Error: \(errorString)", comment: "")
        } else if isSeeding {
            self.detailStatus = self.uploadRateString
        } else if isDownloading {
            self.detailStatus = "\(self.downloadRateString) \(self.uploadRateString) ETA: \(self.etaTimeString)"
        } else if isStopped {
            self.detailStatus = NSLocalizedString("Paused", comment: "TorrentListController torrent info")
        } else if isChecking {
            self.detailStatus = NSLocalizedString("Verifying data ...", comment: "")
        } else if isFinished {
            self.detailStatus = "Completed"
        } else if self.status == .downloadWait {
            self.detailStatus = "Queued, waiting to start Downloading"
        } else if self.status == .seedWait {
            self.detailStatus = "Queued, waiting to start Seeding"
        }  else if self.status == .checkWait {
            self.detailStatus = "Queued, waiting to start Verification"
        }
        
        if !(isStopped || isFinished || isChecking || isWaiting) {
            self.peersDetail = String(format: NSLocalizedString("↓DL %ld and ↑UL %ld from %ld Peers", comment: ""), Int(peersSendingToUs), Int(peersGettingFromUs), Int(peersConnected))
        } else if isStopped {
            self.peersDetail = NSLocalizedString("Paused", comment: "TorrentListController torrent info")
        } else if isFinished {
            self.peersDetail = "Completed"
        } else if isChecking {
            self.peersDetail = NSLocalizedString("Verifying data ...", comment: "")
        } else if isWaiting {
            self.peersDetail = ""
        }

        self.statusString = self.status.statusString
    }
    
    ///
    /// update the torrent propierties copying propierties from torrent passed as parameter
    ///
    open func update(with torrent: Torrent) {
        self.trId = torrent.trId
        self.name = torrent.name
        self.status = torrent.status
        self.percentDone = torrent.percentDone
        self.errorString = torrent.errorString
        self.activityDate = torrent.activityDate
        self.editDate = torrent.editDate
        self.startDate = torrent.startDate
        self.dateDone = torrent.dateDone
        self.totalSize = torrent.totalSize
        self.downloadedEver = torrent.downloadedEver
        self.secondsDownloading = torrent.secondsDownloading
        self.secondsSeeding = torrent.secondsSeeding
        self.uploadRate = torrent.uploadRate
        self.downloadRate = torrent.downloadRate
        self.peersConnected = torrent.peersConnected
        self.peersSendingToUs = torrent.peersSendingToUs
        self.peersGettingFromUs = torrent.peersGettingFromUs
        self.uploadedEver = torrent.uploadedEver
        self.uploadRatio = torrent.uploadRatio
        self.hashString = torrent.hashString
        self.piecesCount = torrent.piecesCount
        self.pieceSize = torrent.pieceSize
        self.comment = torrent.comment
        self.downloadDir = torrent.downloadDir
        self.errorNumber = torrent.errorNumber
        self.creator = torrent.creator
        self.dateCreated = torrent.dateCreated
        self.dateAdded = torrent.dateAdded
        self.haveValid = torrent.haveValid
        self.recheckProgress = torrent.recheckProgress
        self.bandwidthPriority = torrent.bandwidthPriority
        self.honorsSessionLimits = torrent.honorsSessionLimits
        self.peerLimit = torrent.peerLimit
        self.uploadLimited = torrent.uploadLimited
        self.uploadLimit = torrent.uploadLimit
        self.downloadLimited = torrent.downloadLimited
        self.downloadLimit = torrent.downloadLimit
        self.seedIdleMode = torrent.seedIdleMode
        self.seedIdleLimit = torrent.seedIdleLimit
        self.seedRatioMode = torrent.seedRatioMode
        self.seedRatioLimit = torrent.seedRatioLimit
        self.queuePosition = torrent.queuePosition
        self.eta = torrent.eta
        self.haveUnchecked = torrent.haveUnchecked
        self.CommonInit()
    }
    
}
 
 
// MARK: - Comparable Protocol adoption
extension Torrent: Comparable {
    
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

extension Torrent: NSItemProviderWriting, NSItemProviderReading {
    
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


