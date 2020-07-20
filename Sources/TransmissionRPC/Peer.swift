//
//  Peer.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine

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
   
    public init() {
        
    }
}

open class Peer: NSObject, Codable, ObservableObject, Identifiable {
    
    @Published public var ipAddress: String = ""
    @Published public var clientName: String = ""
    @Published public var clientIsChoked: Bool = false
    @Published public var clientIsInterested: Bool = false
    @Published public var flagString: String = ""
    @Published public var isDownloadingFrom: Bool = false
    @Published public var isEncrypted: Bool = false
    @Published public var isIncoming: Bool = false
    @Published public var isUploadingTo: Bool = false
    @Published public var isUTP: Bool = false
    @Published public var peerIsChoked: Bool = false
    @Published public var peerIsInterested: Bool = false
    @Published public var port: Int = 0
    @Published public var progress: Double = 0.0 {
        didSet {
            self.progressString = String(format: "%02.2f%%", progress * 100.0)
        }
    }
    @Published public var rateToClient: Int = 0 {
        didSet {
            rateToClientString = ByteCountFormatter.formatByteRate(rateToClient)
        }
    }
    @Published public var rateToPeer: Int = 0 {
        didSet {
            rateToPeerString = ByteCountFormatter.formatByteRate(rateToPeer)
        }
    }
    
    @Published public var progressString: String = ""
   
    @Published public var rateToClientString: String = ""

    @Published public var rateToPeerString: String = ""
    
    public var id: String {
        return ipAddress
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.ipAddress, forKey: .ipAddress)
        try container.encode(self.clientName, forKey: .clientName)
        try container.encode(self.clientIsInterested, forKey: .clientIsInterested)
        try container.encode(self.clientIsChoked, forKey: .clientIsChoked)
        try container.encode(self.flagString, forKey: .flagString)
        try container.encode(self.isDownloadingFrom, forKey: .isDownloadingFrom)
        try container.encode(self.isEncrypted, forKey: .isEncrypted)
        try container.encode(self.isIncoming, forKey: .isIncoming)
        try container.encode(self.isUploadingTo, forKey: .isUploadingTo)
        try container.encode(self.isUTP, forKey: .isUTP)
        try container.encode(self.peerIsChoked, forKey: .peerIsChoked)
        try container.encode(self.peerIsInterested, forKey: .peerIsInterested)
        try container.encode(self.port, forKey: .port)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.rateToClient, forKey: .rateToClient)
        try container.encode(self.rateToPeer, forKey: .rateToPeer)
        
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.ipAddress = try values.decode(String.self, forKey: .ipAddress)
        self.clientName = try values.decode(String.self, forKey: .clientName)
        self.clientIsInterested = try values.decode(Bool.self, forKey: .clientIsInterested)
        self.clientIsChoked = try values.decode(Bool.self, forKey: .clientIsChoked)
        self.flagString = try values.decode(String.self, forKey: .flagString)
        self.isDownloadingFrom = try values.decode(Bool.self, forKey: .isDownloadingFrom)
        self.isEncrypted = try values.decode(Bool.self, forKey: .isEncrypted)
        self.isIncoming = try values.decode(Bool.self, forKey: .isIncoming)
        self.isUploadingTo = try values.decode(Bool.self, forKey: .isUploadingTo)
        self.isUTP = try values.decode(Bool.self, forKey: .isUTP)
        self.peerIsChoked = try values.decode(Bool.self, forKey: .peerIsChoked)
        self.peerIsInterested = try values.decode(Bool.self, forKey: .peerIsInterested)
        self.port = try values.decode(Int.self, forKey: .port)
        self.progress = try values.decode(Double.self, forKey: .progress)
        self.rateToClient = try values.decode(Int.self, forKey: .rateToClient)
        self.rateToPeer = try values.decode(Int.self, forKey: .rateToPeer)
    }
    
    
    static func == (lhs: Peer, rhs: Peer) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    static func != (lhs: Peer, rhs: Peer) -> Bool {
        return lhs.id != rhs.id
    }
    
    
    open override func isEqual(_ object: Any?) -> Bool {
        return self.id == (object as? Peer)?.id
    }
}
