//
//  JSONStructures.swift
//  TransmissionRPC
//
//  Structures to parse the Transmission server RPC JSON response
//
//  Created by Johnny Vega 
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

/*!
@struct JSONTorrent
@struct JSONTorrentsArguments.
 Structures to parse the torrent-get RPC JSON response.
*/
public struct JSONTorrentsArguments: Codable {
    
    public var torrents: [Torrent]
    public var removed: [trId]?
    private enum CodingKeys: String, CodingKey {
        case torrents
        case removed
    }
}

public struct JSONTorrents: Codable {
    public var arguments: JSONTorrentsArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}



/*!
 @struct JSONTorrentAdded
 @struct JSONTorrentAddedArguments.
 @struct JSONTorrentObject
 Structures to parse the torrent-add RPC JSON response.
 */
public class JSONTorrentObject: NSObject, Codable {
    public var id: Int
    public var name: String
    public var hashString: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case hashString
    }
}

public struct JSONTorrentAddedArguments: Codable {
    public var torrentAdded: JSONTorrentObject?
    public var torrentDuplicate: JSONTorrentObject?
     
    private enum CodingKeys: String, CodingKey {
        case torrentAdded = "torrent-added"
        case torrentDuplicate = "torrent-duplicate"
    }
}

public struct JSONTorrentAdded: Codable {
    public var arguments: JSONTorrentAddedArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}

/*!
 @struct JSONPeers
 @struct JSONPeersArguments.
 @struct JSONPeersObject
 Structures to parse the torrent-get RPC JSON response with the peers and peersFrom object fields.
 */
public struct JSONPeersObject: Codable {
    public var peers: [Peer]
    public var peersFrom: PeerStat
    
    private enum CodingKeys: String, CodingKey {
        case peers
        case peersFrom
    }
}

public struct JSONPeersArguments: Codable {
    
    public var torrents: [JSONPeersObject]
    
    private enum CodingKeys: String, CodingKey {
        case torrents
    }
}

public struct JSONPeers: Codable {
    public var arguments: JSONPeersArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONFileStat
 @struct JSONFileStatArguments.
 @struct JSONFileStatObject
 Structures to parse the torrent-get RPC JSON response with the fileStats object fields.
 */
public struct JSONFileStatObject: Codable {
    public var fileStats: [FileStat]
   
    
    private enum CodingKeys: String, CodingKey {
        case fileStats
    }
}

public struct JSONFileStatArguments: Codable {
    
    public var torrents: [JSONFileStatObject]
    
    private enum CodingKeys: String, CodingKey {
        case torrents
    }
}

public struct JSONFileStat: Codable {
    public var arguments: JSONFileStatArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONTrackerStat
 @struct JSONTrackerStatArguments.
 @struct JSONTrackerStatObject
 Structures to parse the torrent-get RPC JSON response with the trackerStats object fields.
 */
public struct JSONTrackerObject: Codable {
    public var trackerStats: [Tracker]
    
    private enum CodingKeys: String, CodingKey {
        case trackerStats
    }
}

public struct JSONTrackerArguments: Codable {
    
    public var torrents: [JSONTrackerObject]
    
    private enum CodingKeys: String, CodingKey {
        case torrents
    }
}

public struct JSONTracker: Codable {
    public var arguments: JSONTrackerArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONSession
 Structures to parse the session-get RPC JSON response
 */
public struct JSONSession: Codable {
    public var arguments: SessionConfig
    
    private enum CodingKeys: String, CodingKey {
        case arguments
    }
}


/*!
 @struct JSONSession
 Structures to parse the session-stats RPC JSON response for stats
 */
public struct JSONSessionStats: Decodable {
    public var arguments: SessionStats
    
    private enum CodingKeys: String, CodingKey {
        case arguments
    }
}


/*!
 @struct JSONFreeSpace
 @struct JSONFreeSpeceArguments
 Structures to parse the free-space RPC JSON response
 */
public struct JSONFreeSpeceArguments: Codable {
    public var path: String
    public var sizeBytes: Int
    
    private enum CodingKeys: String, CodingKey {
        case path
        case sizeBytes = "size-bytes"
    }
}

public struct JSONFreeSpace: Codable {
    public var arguments: JSONFreeSpeceArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONPortChecking
 @struct JSONPortCheckingArguments
 Structures to parse the port-test RPC JSON response
 */
public struct JSONPortCheckingArguments: Codable {
    public var portIsOpen: Bool
    
    private enum CodingKeys: String, CodingKey {
        case portIsOpen = "port-is-open"
    }
}

public struct JSONPortChecking: Codable {
    public var arguments: JSONPortCheckingArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONTorrentMagnet
 @struct JSONTorrentMagnetArguments
 @struct JSONTorrentMagnetObject
 Structures to parse the torrent-add RPC JSON response using a magnet URL
 */
public struct JSONTorrentMagnetObject: Codable {
    public var magnetLink: String
    
    private enum CodingKeys: String, CodingKey {
        case magnetLink
    }
}

public struct JSONTorrentMagnetArguments: Codable {
    
    public var torrents: [JSONTorrentMagnetObject]
    
    private enum CodingKeys: String, CodingKey {
        case torrents
    }
}

public struct JSONTorrentMagnet: Codable {
    public var arguments: JSONTorrentMagnetArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONTorrentPieces
 @struct JSONTorrentPiecesArguments
 @struct JSONTorrentPiecesObject
 Structures to parse the torrent-get RPC JSON response for the pieces object field
 */
public struct JSONTorrentPiecesObject: Codable {
    public var pieces: Data
    
    private enum CodingKeys: String, CodingKey {
        case pieces
    }
}

public struct JSONTorrentPiecesArguments: Codable {
    
    public var torrents: [JSONTorrentPiecesObject]
    
    private enum CodingKeys: String, CodingKey {
        case torrents
    }
}

public struct JSONTorrentPieces: Codable {
    public var arguments: JSONTorrentPiecesArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
}


/*!
 @struct JSONTorrentRenamePath
 @struct JSONTorrentRenamePathArguments
 Structures to parse the torrent-rename-path RPC JSON response
 */
public struct JSONTorrentRenamePathArguments: Codable {
    
    public var path: String
    public var name: String
    public var id: Int
    
    private enum CodingKeys: String, CodingKey {
        case path
        case name
        case id
    }
}

public struct JSONTorrentRenamePath: Codable {
    public var arguments: JSONTorrentRenamePathArguments
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case arguments
        case result
    }
    
}

public struct JSONResponse: Codable {
    public var result: String
    
    private enum CodingKeys: String, CodingKey {
        case result
    }
}
