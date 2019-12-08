//
//  Peer.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

public struct PeerStat: Codable {
    
    public var fromCache: Int = 0
    public var fromDht: Int = 0
    public var fromIncoming: Int = 0
    public var fromLpd: Int = 0
    public var fromPex: Int = 0
    public var fromTracker: Int = 0
    public var fromLtep: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case fromCache
        case fromDht
        case fromIncoming
        case fromLpd
        case fromLtep
        case fromPex
        case fromTracker
    }
   
}

open class Peer: NSObject, Codable {
    
    public var ipAddress: String = ""
    public var clientName: String = ""
    public var clientIsChoked: Bool = false
    public var clientIsInterested: Bool = false
    public var flagString: String = ""
    public var isDownloadingFrom: Bool = false
    public var isEncrypted: Bool = false
    public var isIncoming: Bool = false
    public var isUploadingTo: Bool = false
    public var isUTP: Bool = false
    public var peerIsChoked: Bool = false
    public var peerIsInterested: Bool = false
    public var port: Int = 0
    public var progress: Double = 0.0
    public var rateToClient: Int = 0
    public var rateToPeer: Int = 0
    
    public var progressString:String {
        return String(format: "%02.2f%%", progress * 100.0)
    }
   
    public var rateToClientString: String {
        return formatByteRate(rateToClient)
    }

    public var rateToPeerString: String {
        return formatByteRate(rateToPeer)
    }
    
    private enum CodingKeys: String, CodingKey {
        case ipAddress = "address"
        case clientIsChoked
        case clientIsInterested
        case clientName
        case flagString = "flagStr"
        case isDownloadingFrom
        case isEncrypted
        case isIncoming
        case isUTP
        case isUploadingTo
        case peerIsChoked
        case peerIsInterested
        case port
        case progress
        case rateToClient
        case rateToPeer
    }
    
}
