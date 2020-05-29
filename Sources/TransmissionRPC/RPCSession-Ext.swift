//
//  RPCSession-Ext.swift
//  TransmissionRPC
//
//  Created by Johnny Vega on 10/11/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

//MARK: - Extension typealias
public typealias TrId = Int

//MARK: - RecentlyActive constant
public let RecentlyActive = [-1]

//MARK: - Enumerations

public enum QueueMovements: String, Codable {
    case top = "queue-move-top"
    case bottom = "queue-move-bottom"
    case up = "queue-move-up"
    case down = "queue-move-down"
}


//MARK: - RPCSession extension
public extension RPCSession {
        
    //MARK: - RPC Torrent Accessors methods
    
    /// Send a RPC request message to the Transmission RPC server to return torrents information
    ///
    /// - parameter trIds:
    ///     Array of torrent Ids.  If parameter value is nil,
    ///     request will return all torrents in server,
    ///     if constant "RecentlyActive" is passed as parameter value,
    ///     request call will return only torrents with recently activity.
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter torrents:
    ///     An array of Torrent objects, each of them containing the respective information
    ///     of returned torrents
    /// - parameter removedTorrents:
    ///     If the request's "ids" field was "recently-active", an array of Torrent Ids numbers of recently-removed torrents.
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func getInfo(_ fields: [JSONKey]? = nil, forTorrents trIds: [TrId]?, withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping (_ torrents:[Torrent]?,_ removedTorrents: [TrId]?,_ error:Error?)->Void) {
        
        var torrentFields: [JSONKey]
        
        if let fields = fields {
            torrentFields = fields
        } else {
            torrentFields = [
                JSONKeys.activityDate,
                JSONKeys.editDate,
                JSONKeys.addedDate,
                JSONKeys.startDate,
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
                JSONKeys.eta,
                JSONKeys.hashString,
                JSONKeys.haveUnchecked,
                JSONKeys.haveValid,
                JSONKeys.honorsSessionLimits,
                JSONKeys.id,
                JSONKeys.isFinished,
                JSONKeys.name,
                JSONKeys.peer_limit,
                JSONKeys.peersConnected,
                JSONKeys.peersGettingFromUs,
                JSONKeys.peersSendingToUs,
                JSONKeys.percentDone,
                JSONKeys.pieceCount,
                JSONKeys.pieceSize,
                JSONKeys.queuePosition,
                JSONKeys.rateDownload,
                JSONKeys.rateUpload,
                JSONKeys.recheckProgress,
                JSONKeys.secondsDownloading,
                JSONKeys.secondsSeeding,
                JSONKeys.seedIdleLimit,
                JSONKeys.seedIdleMode,
                JSONKeys.seedRatioLimit,
                JSONKeys.seedRatioMode,
                JSONKeys.status,
                JSONKeys.totalSize,
                JSONKeys.uploadedEver,
                JSONKeys.uploadLimit,
                JSONKeys.uploadLimited,
                JSONKeys.uploadRatio
            ]
        }
        var arguments = JSONObject()
        arguments[JSONKeys.fields] = torrentFields
        if trIds != nil && !trIds!.isEmpty {
            arguments[JSONKeys.ids] = trIds == RecentlyActive ? JSONKeys.recently_active : trIds
        }
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority,  dataCompletion: { (data, error) in
                
                if error != nil {
                    completion(nil,nil,error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTorrents.self, from: data!)
                    let torrents = response.arguments.torrents
                    let removedTorrents = response.arguments.removed
                    completion(torrents,removedTorrents,nil)
                } catch {
                    completion(nil,nil,error)
                }
            })
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `torrent-get` to return torrent trackers statistics
    ///
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter trackers:
    ///     An Array of Tracker objects, each of them containing a tracker statistics
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func getTrackers(forTorrent trId: TrId, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ trackers: [Tracker]?,_ error: Error?)->Void) {
        let arguments = [
            JSONKeys.fields: [JSONKeys.trackerStats],
            JSONKeys.ids: [trId]
            ] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(nil,error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTracker.self, from: data!)
                    guard let trackers = response.arguments.torrents.first?.trackerStats else {return}
                    completion(trackers,nil)
                }
                catch {
                    completion(nil,error)
                }
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `torrent-get` to return the torrent's peers and peers statistics
    ///
    /// - parameter trId:
    ///     Torrent Id to request peers
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter peers:
    ///     Array of Peers objects, each of them containing a returned peer details
    /// - parameter peerStat:
    ///     PeerStat object containg the returned peers statistics
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func getPeers(forTorrent trId: TrId, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ peers: [Peer]?,_ peerStat: PeerStat?,_ error: Error?)->Void) {
        
        let arguments = [JSONKeys.fields: [JSONKeys.peers,
                                           JSONKeys.peersFrom],
                         JSONKeys.ids: [trId]
            ] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil,nil,error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONPeers.self, from: data!)
                    guard let peers = response.arguments.torrents.first else {return}
                    completion(peers.peers,peers.peersFrom,nil)
                } catch {
                    completion(nil, nil, error)
                }
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `torrent-get` to return the torrent files
    ///
    /// - parameter trId:
    ///     Torrent Id to request files
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter fsDir:
    ///     A FSDirectory object containing the torrent's file in a hierarchy structure
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func getAllFiles(forTorrent trId: TrId, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ fsDir: FSDirectory?,_ error: Error?)->Void) {
        
        let arguments = [JSONKeys.fields: [JSONKeys.files,
                                           JSONKeys.fileStats],
                         JSONKeys.ids: [trId]
            ] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority,  jsonCompletion: { (json,error) in
                if error != nil {
                    completion(nil,error)
                    return
                }
                let torrentsFiles = (json![JSONKeys.arguments] as! JSONObject)[JSONKeys.torrents] as! [JSONObject]
                
                let files = torrentsFiles.first![JSONKeys.files] as? [JSONObject] ?? []
                let fileStats = torrentsFiles.first![JSONKeys.fileStats] as? [JSONObject] ?? []
                
                let fsDir = FSDirectory(withJSONFileInfo: files, jsonFileStatInfo: fileStats, andId: trId)
                
                completion(fsDir,nil)
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    /// Send to Transmission RPC server a request message with method `torrent-get` to return the torrent files
    ///
    /// - parameter trId:
    ///     Torrent Id to request files
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter fsDir:
    ///     A FSDirectory object containing the torrent's file in a hierarchy structure
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func getAllFileStats(forTorrent trId: TrId, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ stats:[FileStat]?,_ error: Error?)->Void) {
        
        let arguments = [JSONKeys.fields: [JSONKeys.fileStats],
                         JSONKeys.ids: [trId]
            ] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority,  dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil,error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONFileStat.self, from: data!)
                    let fileStats = response.arguments.torrents.first!.fileStats
                    completion(fileStats,nil)
                } catch {
                    completion(nil, error)
                }
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-get` to return the the bitfield holding the pieceCount flags
    ///
    /// - parameter trId: Torrent Id to request files
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when
    /// the server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter pieces: A bitfield holding pieceCount flags which are set to 'true'
    /// if we have the piece matching that position.  JSON doesn't allow
    /// raw binary data, so this is a base64-encoded string.
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func getPieces(forTorrent trId: TrId, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ pieces: Data?,_ error: Error?)->Void) {
        
        let arguments = [JSONKeys.fields: [JSONKeys.pieces],
                         JSONKeys.ids: [trId]
            ] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_get, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil,error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTorrentPieces.self, from: data!)
                    guard let data64encoded = response.arguments.torrents.first?.pieces else {return}
                    completion(data64encoded,nil)
                } catch {
                    completion(nil, error)
                    
                }
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    //MARK: - RPC Torrent Action Requests
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-start` to start processing the respective Torrents
    ///
    /// - parameter trIds: Array of Torrents Id to start downloading/uploading
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    ///
    func start(torrents trIds: [TrId]?, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        var arguments: JSONObject?
        if trIds != nil {
            arguments = [JSONKeys.ids: trIds!] as JSONObject
        }
        let request = RPCRequest(forMethod: JSONKeys.torrent_start, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion:  { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-start-now` to start inmediately the processing
    /// of the respective Torrents
    ///
    /// - parameter trIds: Array of Torrents Id to start inmediately
    /// the downloading/uploading
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    ///
    func startNow(torrents trIds: [TrId]?, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        var arguments: JSONObject?
        if trIds != nil {
            arguments = [JSONKeys.ids: trIds!] as JSONObject
        }
        let request = RPCRequest(forMethod: JSONKeys.torrent_start_now, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion:  { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-stop` to stop processing the respective Torrents
    ///
    /// - parameter trIds: Array of Torrents Id to stop downloading/uploading
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    ///
    func stop(torrents trIds: [TrId]?, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        var arguments: JSONObject?
        if trIds != nil {
            arguments = [JSONKeys.ids: trIds!] as JSONObject
        }
        let request = RPCRequest(forMethod: JSONKeys.torrent_stop, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion:  { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-reannounce` to update the trackers and ask for additional peers
    ///
    /// - parameter trIds: Array of Torrents Id to reannounce
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    ///
    func reannounce(torrents trIds: [TrId]?, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        var arguments: JSONObject?
        if trIds != nil {
            arguments = [JSONKeys.ids: trIds!] as JSONObject
        }
        let request = RPCRequest(forMethod: JSONKeys.torrent_reannounce, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }

    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-verify` to verify the file data of the respective Torrents
    ///
    /// - parameter trIds: Array of Torrents Id to verify
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func verify(torrents trIds: [TrId], withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        let arguments = [JSONKeys.ids: trIds] as JSONObject
       let request = RPCRequest(forMethod: JSONKeys.torrent_verify, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-add` to add a new Torrent
    ///
    /// - parameter torrentFile: TorrentFile object including the data
    /// of torrent to add
    /// - parameter bandPriority: Bandwith priority to assign to torrent
    /// - parameter paused: if true, don't start the torrent.
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func addTorrent(usingFile torrentFile: TorrentFile, andBandwithPriority bandPriority: Int? = 0, addPaused paused: Bool, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ trId: TrId?, _ error: Error?)->Void) {
        
        let torrentFile = torrentFile
        let base64content = torrentFile.torrentData.base64EncodedString(options: .lineLength64Characters)
        
        let rpcFileIndexesUnwanted = torrentFile.fs.rpcIndexesUnwanted
        let rpcFileIndexesHighPriority = torrentFile.fs.rpcIndexesHighPriority
        let rpcFileIndexesLowPriority = torrentFile.fs.rpcIndexesLowPriority
        
        var arguments = [ JSONKeys.metainfo: base64content,
                          JSONKeys.paused: paused
                        ] as [JSONKey : Any]
        arguments[JSONKeys.bandwidthPriority] = bandPriority
        arguments[JSONKeys.files_unwanted] = rpcFileIndexesUnwanted.isEmpty ? nil : rpcFileIndexesUnwanted
        arguments[JSONKeys.priority_high] = rpcFileIndexesHighPriority.isEmpty ? nil : rpcFileIndexesHighPriority
        arguments[JSONKeys.priority_low] = rpcFileIndexesLowPriority.isEmpty ? nil : rpcFileIndexesLowPriority
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_add, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(nil,error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONTorrentAdded.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(nil,error)
                    } else if response.arguments.torrentDuplicate != nil {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: "Torrent is duplicated"])
                        completion(nil,error)
                    }
                    else {
                        let trId = response.arguments.torrentAdded?.id
                        completion(trId,nil)
                    }
                } catch {
                    completion(nil,error)
                }
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    //MARK: - RPC Torrent Mutators methods
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-set` to update a list of torrent's fields
    /// - parameter fields:
    ///     Array of fields to update in the list of torrents
    /// - parameter trIds:
    ///     Array of torrent Ids.  If parameter value is nil,
    ///     request will update fields for all torrents in server,
    ///     if constant "RecentlyActive" is passed as parameter value,
    ///     request call will update only torrents with recent activity.
    /// - parameter queuePriority:
    ///     The execution priority of the request in the requests operation queue.
    /// - parameter completion:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter error:
    ///     An error object that indicates why the request failed, or nil if the request was successful.
    func setFields(_ fields: JSONObject, forTorrents trIds: [TrId], withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void) {
        
        var arguments = fields
        arguments[JSONKeys.ids] = trIds
        
        let request = RPCRequest(forMethod: JSONKeys.torrent_set, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-remove` to remove the respective Torrents
    ///
    /// - parameter trIds: Array of Torrents Id to remove
    /// - parameter deleteFlag: delete local data if true.
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func remove(torrents trIds: [TrId], deletingLocalData deleteFlag: Bool, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void)  {
        
        let arguments = [JSONKeys.ids: trIds,
                         JSONKeys.delete_local_data: deleteFlag] as JSONObject
        let request = RPCRequest(forMethod: JSONKeys.torrent_remove, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-rename-path` to rename a torrent file
    ///
    /// - parameter filename: Name for file to remane
    /// - parameter trId: Torrent Id for torrent file
    /// - parameter name: New file name
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func renameFile(_ filename: String, forTorrent trId: TrId, usingName name: String, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void)  {
        
        let arguments = [JSONKeys.ids: [trId],
                         JSONKeys.path: filename,
                         JSONKeys.name: name
            ] as JSONObject
        let request = RPCRequest(forMethod: JSONKeys.torrent_rename_path, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `torrent-set-location` to move the torrent files to a
    /// different location
    ///
    /// - parameter trId: Torrent Id for torrent file
    /// - parameter location: The new torrent location
    /// - parameter move: Boolean value.  If true, move from previous location,
    /// otherwise, search "location" for files (default: false)
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func setLocation(forTorrent trId: TrId, location directory: String, move flag: Bool = false, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void)  {
        
        let arguments = [JSONKeys.ids: [trId],
                         JSONKeys.location: directory,
                         JSONKeys.move: flag
            ] as JSONObject
        let request = RPCRequest(forMethod: JSONKeys.torrent_set_location, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
            if error != nil {
                completion(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let response = try decoder.decode(JSONResponse.self, from: data!)
                if response.result != "success" {
                    let error = NSError(domain: "TransmissionRemote", code: 1999, userInfo: [NSLocalizedDescriptionKey: response.result])
                    completion(error)
                } else {
                    completion(nil)
                }
            } catch {
                completion(error)
            }
        })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with
    /// method `"queue-move-<M>"` to move torrents in the queue based
    /// in the `<M>` value.  Where `<M>` is one of the
    /// following values: up, top, down or bottom.  Example: `queue-move-up`
    ///
    /// - parameter trIds: Array of Torrents Id to move in queue
    /// - parameter queueMovement: movement to request (up, top, down, bottom)
    /// - parameter queuePriority: The execution priority of the request
    /// in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    /// This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    func move(torrents trIds: [TrId], to queueMovement: QueueMovements, withPriority queuePriority: Operation.QueuePriority = .normal, completionHandler completion: @escaping(_ error: Error?)->Void ) {
        
        let arguments = [JSONKeys.ids: trIds] as JSONObject
        
        let request = RPCRequest(forMethod: queueMovement.rawValue, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data, error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        torrentQueue.addOperation(request)
    }
    
    // MARK: - RPC Session Accessors Requests
    
    /// Send to Transmission RPC server a request message with method `session-get`
    /// to return the server configuration
    ///
    /// - parameter queuePriority: The execution priority of the request in the
    /// requests operation queue.
    /// - parameter completion: The completion handler to call when the
    /// server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter config: A SessionConfig object containing the returned
    /// server configuration
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func getSessionConfig(withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping(_ config: SessionConfig?,_ error: Error?)->Void) {
        let request = RPCRequest(forMethod: JSONKeys.session_get, withArguments: nil, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONSession.self, from: data!)
                    let config = response.arguments
                    completion(config,nil)
                } catch {
                    completion(nil, error)
                }
            })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `session-stats` to return the session statistics
    ///
    /// - parameter queuePriority: The execution priority of the request in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter stats: A SessionStats object containing the returned session statistics
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func getSessionStats(withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping(_ stats: SessionStats?,_ error: Error?)->Void) {
        let request = RPCRequest(forMethod: JSONKeys.session_stats, withArguments: nil, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONSessionStats.self, from: data!)
                    let stats = response.arguments
                    completion(stats,nil)
                } catch {
                    completion(nil, error)
                }
            })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `test-port` to
    /// validate is port is open
    ///
    /// - parameter queuePriority: The execution priority of the request in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response
    /// is received.
    ///   This completion handler takes the following parameters:
    /// - parameter isOpen: If request was successful, true is port is open,
    /// false is not.  Otherwise nil
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func testPort(withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping(_ isOpen: Bool?,_ error: Error?)->Void) {
        let request = RPCRequest(forMethod: JSONKeys.port_test, withArguments: nil, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONPortChecking.self, from: data!)
                    let isOpen = response.arguments.portIsOpen
                    completion(isOpen,nil)
                } catch {
                    completion(nil, error)
                }
            })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
    
    /// Send to Transmission RPC server a request message with method `free-space` tests how much
    /// free space is available in a specified folder.
    ///
    /// - parameter directory: directory path to query
    /// - parameter queuePriority: The execution priority of the request in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server response is received.
    ///   This completion handler takes the following parameters:
    /// - parameter freeSpace: If request was successful, the size, in bytes,
    /// of the free space in that directory.  Otherwise nil
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func getFreeSpace(availableIn directory: String, withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping(_ freeSpece: Int?,_ error: Error?)->Void) {
        
        let arguments = [JSONKeys.path: directory] as JSONObject
        
        let request = RPCRequest(forMethod: JSONKeys.free_space, withArguments: arguments, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONFreeSpace.self, from: data!)
                    let freeSpace = response.arguments.sizeBytes
                    completion(freeSpace,nil)
                } catch {
                    completion(nil, error)
                }
            })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
    
    //MARK: - RPC Session Mutators Requests
    
    /// Send to Transmission RPC server a request message with method `session-set`
    /// to update the session configuration options
    ///
    /// - parameter config: a SessionConfig object with the configuration options values
    /// - parameter queuePriority: The execution priority of the request in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server
    /// response is received.
    ///    This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func setSessionConfig(usingConfig config: SessionConfig, withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping (_ error: Error?) -> Void) {
        
        let request = RPCRequest(forMethod: JSONKeys.session_set, withArguments: config.jsonForRPC, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
                if error != nil {
                    completion(error)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let response = try decoder.decode(JSONResponse.self, from: data!)
                    if response.result != "success" {
                        let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                        completion(error)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(error)
                }
                
            })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
    /// This method tells the transmission session to shut down.
    ///
    /// - parameter queuePriority: The execution priority of the request in the requests operation queue.
    /// - parameter completion: The completion handler to call when the server
    /// response is received.
    ///    This completion handler takes the following parameters:
    /// - parameter error: An error object that indicates why the request failed,
    /// or nil if the request was successful.
    func shutdownSession(withPriority queuePriority: Operation.QueuePriority = .normal, andCompletionHandler completion: @escaping (_ error: Error?) -> Void) {
        
        let request = RPCRequest(forMethod: JSONKeys.session_close, withArguments: nil, usingSession: self, andPriority: queuePriority, dataCompletion: { (data,error) in
            if error != nil {
                completion(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let response = try decoder.decode(JSONResponse.self, from: data!)
                if response.result != "success" {
                    let error = NSError(domain: "TransmissionRemote", code: 999, userInfo: [NSLocalizedDescriptionKey: response.result])
                    completion(error)
                } else {
                    self.xTransSessionId = nil
                    completion(nil)
                }
            } catch {
                completion(error)
            }
            
        })
        request.queuePriority = queuePriority
        sessionConfigQueue.addOperation(request)
    }
    
}
