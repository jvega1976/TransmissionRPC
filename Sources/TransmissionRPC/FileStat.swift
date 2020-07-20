//
//  FileStat.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.



import Foundation


public struct FileStat: Codable {

    public var bytesCompleted: Double = 0
    public var wanted : Bool = false
    public var priority: FilePriority

    private enum CodingKeys: String, CodingKey {
        case bytesCompleted
        case wanted
        case priority
    }
}

public struct FileStats: Codable {
    public var trId: TrId
    public var fileStats: [FileStat]
    
    private enum CodingKeys: String, CodingKey {
        case trId = "id"
        case fileStats
    }
}
