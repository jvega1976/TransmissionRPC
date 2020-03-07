//
//  TransmissionRPCTests.swift
//  TransmissionRPCTests
//
//  Created by  on 7/11/19.
//

#if !os(macOS)
import UIKit
#endif
import Categorization
import XCTest
@testable import TransmissionRPC

extension Torrent: CategoryItem {
    public func update(with torrent: Torrent) {
        self.trId = torrent.trId
        self.name = torrent.name
        self.status = torrent.status
        self.percentDone = torrent.percentDone
        self.dateDone = torrent.dateDone
        self.errorString = torrent.errorString
        self.activityDate = torrent.activityDate
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
struct PieceRow: Identifiable {
    var id: UUID = UUID()
    var cols: [PieceCol] = []
    
    init(_ long: Int) {
        id = UUID()
        cols = Array(repeating: PieceCol(), count: long)
    }
}

struct PieceCol: Identifiable {
    var id: UUID = UUID()
    var filled: Bool = false
}


class TransmissionRPCTests: XCTestCase {
    
    let MAXACROSS = 20
    var session: RPCSession!
    let sema = DispatchSemaphore(value: 0)
    var categorization: Categorization<Torrent>!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let url = URL(string: "http://jvega:Nmjcup0112*@diskstation.johnnyvega.net:9091/transmission/rpc")
        print(url!.absoluteString)
        session = try? RPCSession(withURL: url!, andTimeout:10)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.session?.getPieces(forTorrent: 4999, withPriority: .veryHigh) { pieces, error in
            if error == nil {
                let pieces = (pieces! as NSData)
                var pointer = pieces.bytes
                let maxrc = min(2231, self.MAXACROSS*self.MAXACROSS)
                let accross = Int(ceil(sqrt(Double(maxrc))))
                var shift = 0
                var array: Array<PieceRow> = Array(repeating: PieceRow(accross), count: accross)
                for index in 0..<maxrc {
                    let col = index % accross
                    let row = index / accross
                    
                    let c = pointer.load(as: UInt8.self)
                    let filled = (c >> shift) & 0x1 != 0 ? true : false
                    shift += 1
                    if shift > 7 {
                        shift = 0
                        pointer += 1
                    }
                    array[row].cols.insert(PieceCol(filled: filled), at: col)
                }
                DispatchQueue.main.async {
                    print(array)
                }
            } else {
                DispatchQueue.main.async {
                    print(error!.localizedDescription)
                }
            }
            self.sema.signal()
        }
       sema.wait()
//        print(trInfos.items.count)
    }

    func testPerformanceExample() {
        
        self.measure {
           
        }
    }
    
}
