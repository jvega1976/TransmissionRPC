//
//  FSDirectory.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

//
//  FSDirectory.swift
//  TransmissionRPCClient
//
//  File System Directory data class
//  holds file/directory tree
//  using for representation on UITableView

import Foundation
import Combine

fileprivate let PATH_SPLITTER_STRING = "/"
let TR_ARG_FIELDS_FILE_PATHCOMPONENTS = "pathComponents"

//MARK: - FSDirectory structure

open class FSDirectory: NSObject, ObservableObject, Identifiable, Codable {

    private var folderItems = [AnyHashable : Any]()
    private var rpcIndexFiles = [Int: FSItem]()
    
    
    @Published public var id: Int = 0
    
    /// Get root FSItem
    @Published public private (set) var rootItem: FSItem
    
    /// Initializer
    public init(for trId: TrId? = nil) {
        self.rootItem = FSItem(fullName: "", isFolder: true) // init root element (always folder)
        self.id = trId ?? 1
        super.init()
        self.folderItems = [:]
    }
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case rootItem
        case id
        case rpcIndexFiles
    }
    
    
    /// Initializer, filling Directory items with JSON objects content
    ///
    /// - parameter files: Array of JSON objects containing file properties
    /// - parameter fileStats: Array of JSON objects containing file statistics
    /// return: A new FSDirectory object containing all Files for one particular Torrent
    
    convenience public init(withJSONFileInfo files: [JSONObject], jsonFileStatInfo fileStats:[JSONObject], andId id:Int) {
        self.init()
        self.id = id
        for i in 0..<files.count {
            var file = files[i]
            let fullName = file[JSONKeys.name] as! String
            let pathComponents = fullName.components(separatedBy: PATH_SPLITTER_STRING)
            file[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] = pathComponents
            rootItem.addPathComponents(withJSONFileInfo: &file, jsonFileStatInfo: fileStats[i], rpcIndex: i)
        }
        rootItem.items?.forEach { item in
            item.parent = nil
        }
        self.filter()
        self.sort()
        rpcIndexFiles = rootItem.rpcFileIndexes
    }
    
    
    /// Initializer, filling Directory items with JSON objects content
    ///
    /// - parameter files: Array of JSON objects containing file properties
    /// - parameter fileStats: Array of JSON objects containing file statistics
    /// return: A new FSDirectory object containing all Files for one particular Torrent
    
    convenience public init(withFiles files: [File], stats fileStats:[FileStat], andId id: Int) {
        self.init()
        self.id = id
        for i in 0..<files.count {
            var file = files[i]
            let fullName = file.name
            let pathComponents = fullName.components(separatedBy: PATH_SPLITTER_STRING)
            file.pathComponents = pathComponents
            rootItem.addPathComponents(withFile: &file, andStat: fileStats[i], rpcIndex: i)
        }
        rootItem.items?.forEach { item in
            item.parent = nil
        }
        self.filter()
        self.sort()
        rpcIndexFiles = rootItem.rpcFileIndexes
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(TrId.self, forKey: .id)
        rootItem = try values.decode(FSItem.self, forKey: .rootItem)
        rpcIndexFiles = try values.decode([Int: FSItem].self, forKey: .rpcIndexFiles)
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rootItem, forKey: .rootItem)
        try container.encode(id, forKey: .id)
        try container.encode(rpcIndexFiles, forKey: .rpcIndexFiles)
    }
    
    
    
    /// Sort all folders/files included in directory
    public func sort() {
        if let predicate = self.sortPredicate {
            rootItem.sort(by: predicate)
        } else {
            rootItem.sort(by: <)
        }
    }
    
    public func filter() {
        var finalFilter: ((FSItem)->Bool)? = nil
        if let filterPredicate = filterPredicate {
            finalFilter = { item in filterPredicate(item) || !(item.items?.isEmpty ?? true) }
        }
        rootItem.filter(finalFilter)
    }
    
    
    public var sortPredicate: ((FSItem,FSItem)->Bool)? {
        didSet {
            self.sort()
        }
    }
    
    public var filterPredicate: ((FSItem)->Bool)? {
        didSet {
            self.filter()
        }
    }
    
    
    public func item(at rpcIndex: Int) -> FSItem? {
        return rpcIndexFiles[rpcIndex]
    }
    
    public func item(withName name: String) -> FSItem? {
        return rootItem.findItem(withName: name)
    }
    
    public var rpcIndexesUnwanted: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            !(item.isWanted ?? false)
        }
        return Array(indexes.keys)
    }
    
    public var rpcIndexesLowPriority: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            item.priority == FilePriorityLow
        }
        return Array(indexes.keys)
    }
    
    public var rpcIndexesHighPriority: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            item.priority == FilePriorityHigh
        }
        return Array(indexes.keys)
    }
    
    public func updateFSDir(usingStats fileStats:[JSONObject]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            self.rpcIndexFiles[i]?.bytesCompleted = (file[JSONKeys.bytesCompleted] as! Double)
            if self.rpcIndexFiles[i]?.isWanted != (file[JSONKeys.wanted] as? Bool) {
                self.rpcIndexFiles[i]?.isWanted = file[JSONKeys.wanted] as? Bool
            }
            if self.rpcIndexFiles[i]?.priority != (file[JSONKeys.priority] as! FilePriority) {
                self.rpcIndexFiles[i]?.priority = file[JSONKeys.priority] as! FilePriority
            }
        }
    }
    
    public func updateFSDir(usingStats fileStats:[FileStat]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            self.rpcIndexFiles[i]?.bytesCompleted = file.bytesCompleted
            if self.rpcIndexFiles[i]?.isWanted != file.wanted {
                self.rpcIndexFiles[i]?.isWanted = file.wanted
            }
            if  self.rpcIndexFiles[i]?.priority != file.priority {
                self.rpcIndexFiles[i]?.priority = file.priority
            }
        }
    }
    
    public func updateFSDir(with fsDir: FSDirectory) {
        if fsDir.id == self.id {
            if !(rootItem.items!.isEmpty) {
                for i in 0..<(rootItem.items?.count ?? 0) {
                    self.rootItem.items![i].update(withFSItem: fsDir.rootItem.items![i])
                    self.rootItem.items![i].parent = nil
                }
            } else {
                self.rootItem.items!.append(contentsOf: fsDir.rootItem.items!)
                self.rpcIndexFiles = rootItem.rpcFileIndexes
            }
        }
    }
    
    
    public override var description: String {
        return rootItem.description
    }
    
    public static func == (lhs: FSDirectory, rhs: FSDirectory) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func != (lhs: FSDirectory, rhs: FSDirectory) -> Bool {
        return lhs.id != rhs.id
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let fsDir = object as? FSDirectory else { return false}
        return fsDir.id == self.id
    }
}


// MARK: - TorrentFile initializer extension

extension FSDirectory {
    
    /// add new item to directory with file path
    public func addFilePath(_ path: String, andRpcIndex rpcIndex: Int) -> FSItem {
        // split the path string
        let pathComponents = path.components(separatedBy: PATH_SPLITTER_STRING)
        
        return addPathComonents(pathComponents, andRpcIndex: rpcIndex)
    }
    
    /// add new item to directory with separated file path
    public func addPathComonents(_ pathComponents: [String], andRpcIndex rpcIndex: Int) -> FSItem {
        // add all components to the tree (from root)
        var levelItem = rootItem
        
        let c = pathComponents.count
        
        var cPath = ""
        
        for level in 0..<c {
            let itemName = pathComponents[level]
            
            // last item in array is file, the others - folders
            let isFolder = level != (c - 1)
            
            cPath += itemName
            cPath += "/"
            
            if isFolder  && folderItems[cPath] != nil {
                levelItem = folderItems[cPath] as! FSItem
                continue
            }
            let fullName = (cPath as NSString).substring(to: cPath.count - 1)
            
            levelItem = levelItem.add(withFullName: fullName, isFolder: isFolder)
            
            // cache folder item
            if isFolder {
                folderItems[cPath] = levelItem
                //os_log(@"%@", levelItem.fullName);
            } else {
                levelItem.rpcIndex = rpcIndex
            }
        }
        rpcIndexFiles = rootItem.rpcFileIndexes
        return levelItem
    }
    
    
    
}
