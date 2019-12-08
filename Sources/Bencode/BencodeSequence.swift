//
//  BencodeSequence.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 15..
//

import Foundation

internal struct BencodeIterator: IteratorProtocol {
    
    internal typealias Element = (key: String?, value: Bencode)
    
    private let bencodeOptional: BencodeOptional
    private let sortedKeys: [BencodeKey]
    private var index: Int = 0
    
    init(bencodeOptional: BencodeOptional) {
        self.bencodeOptional = bencodeOptional
        sortedKeys = bencodeOptional.bencode?.dict?.keys.sorted() ?? []
    }
    
    init(bencode: Bencode) {
        self.init(bencodeOptional: .bencode(bencode))
    }
    
    internal mutating func next() -> Element? {
        guard let bencode = bencodeOptional.bencode
            else { return nil }
        
        switch bencode {
        case .list(let l) where index < l.count:
            defer { index += 1 }
            return (key: nil, value: l[index])
        case .dictionary(let d):
            guard index < sortedKeys.count else { return nil }
            defer { index += 1 }
            let key = sortedKeys[index]
            return (key: key.key, value: d[key]!)
        default: return nil
        }
    }
}

extension Bencode: Sequence {
    
    internal func makeIterator() -> BencodeIterator {
        return BencodeIterator(bencode: self)
    }
}

extension BencodeOptional: Sequence {
    
    internal func makeIterator() -> BencodeIterator {
        return BencodeIterator(bencodeOptional: self)
    }
}
