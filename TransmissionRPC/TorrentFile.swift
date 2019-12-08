//
//  TorrentFile.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

private let TRSIZE_NOT_DEFINED = -1
private let kInfoKey = "info"
private let kNameKey = "name"
private let kLengthKey = "length"
private let kFilesKey = "files"
private let kFilePathKey = "path"
private let kAnnounceKey = "announce"
private let kAnnounceListKey = "announce-list"
private let kEmptyString = ""

public struct TorrentFile {
   private var fileData: Data!
   private var benDict: Bencode!
   public var fs: FSDirectory! // cached file list directory
   private var trList: [String]! // cached tracker list array
   private var trSize: Int = 0

    /// init and return new instance of TorrentFile
    /// or nil if file can not be parsed or readed

    public var name: String {
        return benDict![kInfoKey][kNameKey].string ?? ""
    }

    public var trackerList: [String] {
        mutating get {
            //if trList
            if trList != nil {
                return trList!
            }

            var list: [String] = []
            let tracker = benDict?[kAnnounceKey]
            let trackers = benDict?[kAnnounceListKey]
            if trackers != BencodeOptional.none {
                list = []
                trackers!.values.forEach {arr in
                    if let url = URL(string: arr[0].string!) {
                        list.append(url.host!)
                    }
                }
            } else if tracker != BencodeOptional.none {
                list = []
                let url = URL(string: tracker!.string!)
                list.append(url?.absoluteString ?? "")
            }

            if let count = (list.count > 0 ) ? list : nil {
                trList = count
            }

            return trList!
            
        }
    }

    public var fileList: FSDirectory {
        mutating get {
            if fs != nil {
                return fs
            }

            let info = benDict?[kInfoKey]
            let fileDescs = info?[kFilesKey]

            if fileDescs != nil && (fileDescs?.list?.count ?? 0) > 0 {
                fs = FSDirectory()
                var idx = 0

                fileDescs?.values.forEach { fileDesc in
                    let list = fileDesc[kFilePathKey].list
                    var array:[String] = []
                    for i in list ?? [] {
                        array.append(i.string!)
                    }
                    let item:FSItem = fs.addPathComonents(array, andRpcIndex: idx)
                    item.size = fileDesc[kLengthKey].int!
                    item.isWanted = true
                    item.downloadProgress = 0.0
                    idx += 1
                }

                fs?.sort()
            } else {
                fs = FSDirectory()
                let item = fs.addFilePath(benDict?[kInfoKey][kNameKey].string ?? "", andRpcIndex: 0)
                item.isWanted = true
                item.downloadProgress = 0.0
            }
            
            return fs
        }
    }

    public var torrentSize: Int {
        mutating get {
            if Int(trSize) != TRSIZE_NOT_DEFINED {
                return trSize
            }

            if benDict?[kInfoKey][kLengthKey] != nil {
                trSize = benDict?[kInfoKey][kLengthKey].int ?? 0
                return trSize
            } else {
                trSize = 0
                let fileDescs = benDict?[kInfoKey][kFilesKey]

                if fileDescs != nil {
                    fileDescs?.values.forEach { fileDesc in
                        trSize += fileDesc[kLengthKey].int ?? 0
                    }
                }

                return trSize
            }
        }
    }

    public var torrentSizeString: String {
        mutating get {
            return formatByteCount(torrentSize)
        }
    }

    public var torrentData: Data {
        return fileData
    }

    public init(fileURL: URL) {
        do {
            fileData = try Data(contentsOf: fileURL)
            if (fileData != nil) {
                benDict = Bencode(file: fileURL)
            }
        } catch { print(error) }
    }
}
