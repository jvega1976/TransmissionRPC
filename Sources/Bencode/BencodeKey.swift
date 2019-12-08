//
//  BencodeKey.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 16..
//

import Foundation

/** For ordered encoding. */
internal struct BencodeKey {
    
    internal let key: String
    
    internal let order: Int
    
    init(_ key: String, order: Int = Int.max) {
        self.key = key
        self.order = order
    }
}

extension BencodeKey: Equatable, Hashable {
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    internal static func ==(lhs: BencodeKey, rhs: BencodeKey) -> Bool {
        return lhs.key == rhs.key
    }
    
}

extension BencodeKey: Comparable {
    
    internal static func <(lhs: BencodeKey, rhs: BencodeKey) -> Bool {
        if lhs.order != rhs.order {
            return lhs.order < rhs.order
        } else {
            return lhs.key < rhs.key
        }
    }
}

// MARK: - String helper extension

extension String {
    
    /** Convert string to BencodeKey */
    var bKey: BencodeKey {
        return BencodeKey(self)
    }
}
