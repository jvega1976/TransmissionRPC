//
//  FileStat.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.



import Foundation


public struct FileStat: Codable {

    public var bytesCompleted: Int = 0
    public var wanted : Bool = false
    public var priority: Int

    public var bytesCompletedString: String {
        return ByteCountFormatter.formatByteCount(bytesCompleted)
    }
    
    private enum CodingKeys: String, CodingKey {
        case bytesCompleted
        case wanted
        case priority
    }
}
