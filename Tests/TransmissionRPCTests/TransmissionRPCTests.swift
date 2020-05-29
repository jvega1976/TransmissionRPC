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


struct TorrentActive: Codable {
    public var name: String = ""
    public var trId: TrId
    public var activityDate: Date?
    public var editDate: Date?
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case trId = "id"
        case activityDate = "activityDate"
        case editDate = "editDate"
    }
}

struct JSONTorrentActiveArguments: Codable {
    
    public var torrents: [TorrentActive]
    public var removed: [trId]?
    private enum CodingKeys: String, CodingKey {
        case torrents
        case removed
    }
}

struct JSONTorrentsActive: Codable {
    public var arguments: JSONTorrentActiveArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}

class TransmissionRPCTests: XCTestCase {
    
    let MAXACROSS = 20
    var session: RPCSession!
    let sema = DispatchSemaphore(value: 0)
    var categorization: Categorization<Torrent>!
    var array = Array<Torrent>()
    var newArray: Array<Torrent>?
    var latUpdate: Date!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let url = URL(string: "http://jvega:Nmjcup0112*@diskstation.johnnyvega.net:9091/transmission/rpc")
        print(url!.absoluteString)
        session = try? RPCSession(withURL: url!, andTimeout:10)
        self.categorization = Categorization()
        
        self.session?.getInfo(forTorrents: nil, withPriority: .veryHigh, andCompletionHandler: { torrents,_,error in
         if error != nil {
         print(error!.localizedDescription)
         } else {
            self.categorization.setItems(torrents!)
         }
         self.sema.signal()
         })
         sema.wait()
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        self.measure {
            
            let lastUpdate = Date(timeIntervalSinceNow: -1800)
            var arguments = JSONObject()
            arguments[JSONKeys.fields] =  [JSONKeys.id, JSONKeys.name, JSONKeys.status, JSONKeys.activityDate]
            
            
            let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self.session, andPriority: .veryHigh, dataCompletion:  { (data, error) in
                
                if error != nil {
                    print("TransmissionRemoteSwiftUI: %@",error!.localizedDescription)
                    self.sema.signal()
                    return
                }
                var torrents: [TorrentActive]?
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTorrentsActive.self, from: data!)
                    torrents = response.arguments.torrents
                } catch {
                    self.sema.signal()
                    return
                }
                if let trIds = torrents?.filter({ $0.activityDate ?? Date(timeIntervalSince1970: 0) >= lastUpdate || $0.editDate ?? Date(timeIntervalSince1970: 0) >= lastUpdate }).map({$0.trId}),
                    !(trIds.isEmpty)
                {
                    print("trIds: \(trIds)")
                    self.session?.getInfo(forTorrents: trIds, withPriority: .veryHigh, andCompletionHandler: { torrents,_,error in
                        
                        if error != nil {
                            print(error!.localizedDescription)
                        } else if !(torrents?.isEmpty ?? true) {
                            self.categorization.updateItems(with: torrents!)
                        }
                        self.sema.signal()
                    })
                }

                self.sema.signal()
            })
            self.session.addTorrentRequest(request)
            self.sema.wait()
        }
    }

    func testPerformanceExample() {
        
    }
    
}
