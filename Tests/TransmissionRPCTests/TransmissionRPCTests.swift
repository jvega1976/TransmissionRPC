//
//  TransmissionRPCTests.swift
//  TransmissionRPCTests
//
//  Created by  on 7/11/19.
//

#if !os(macOS)
import UIKit
#endif
import XCTest
@testable import TransmissionRPC


class TransmissionRPCTests: XCTestCase {
    
    var session: RPCSession!
    let sema = DispatchSemaphore(value: 0)
    var operationQueue: OperationQueue!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let url = URL(string: "http://jvega:Nmjcup0112*@diskstation.johnnyvega.net:9091/transmission/rpc")
        print(url!.absoluteString)
        session = try? RPCSession(withURL: url!, andTimeout:10)
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let fields = [
                JSONKeys.activityDate,
                JSONKeys.addedDate,
                JSONKeys.bandwidthPriority,
                JSONKeys.comment,
                JSONKeys.creator,
                JSONKeys.dateCreated,
                JSONKeys.doneDate,
                JSONKeys.downloadDir,
                JSONKeys.downloadedEver,
                JSONKeys.downloadLimit,
                JSONKeys.downloadLimited,
                JSONKeys.error,
                JSONKeys.errorString,
                JSONKeys.eta
            ]
        var arguments = JSONObject()
        arguments[JSONKeys.fields] = fields
       
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: session, andPriority: .veryHigh, dataCompletion: { (data, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let response = try decoder.decode(JSONTorrents.self, from: data!)
                let torrents = response.arguments.torrents.sorted(by: >)
                let removedTorrents = response.arguments.removed
                print(torrents[0])
                print(torrents.count)
                print(removedTorrents?.count ?? 0)
            } catch {
                print(error.localizedDescription)
            }
        })
        arguments[JSONKeys.ids] = JSONKeys.recently_active
        let request1 = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: session, andPriority: .normal, dataCompletion: { (data, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let response = try decoder.decode(JSONTorrents.self, from: data!)
                let torrents = response.arguments.torrents.sorted(by: >)
                let removedTorrents = response.arguments.removed
                print(torrents[0])
                print(torrents.count)
                print(removedTorrents?.count ?? 0)
            } catch {
                print(error.localizedDescription)
            }
            self.sema.signal()
        })
        
        operationQueue.addOperation(request)
        operationQueue.addOperation(request1)
        sema.wait()
//        print(trInfos.items.count)
    }

    func testPerformanceExample() {
        
        self.measure {
           
        }
    }
    
}
