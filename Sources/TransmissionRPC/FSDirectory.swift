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

open class FSDirectory: NSObject, ObservableObject, Identifiable {

    private var folderItems = [AnyHashable : Any]()
    private var rpcIndexFiles = [Int: FSItem]()
    
    /// Get count of items in directory
    private var _count = -1
    public var count: Int {
        get {
            if _count == -1 {
                _count = rootItem.filesCount
            }
            return _count
        }
    }
    
    @Published public var id: Int
    
    /// Get root FSItem
    @Published public private (set) var rootItem: FSItem
    
    /// Initializer
    public override init() {
        self.rootItem = FSItem(name: "", isFolder: true) // init root element (always folder)
        self.id = 1
        super.init()
        self.rootItem.indexPath = IndexPath()
        self.folderItems = [:]
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
        self.sort()
        rpcIndexFiles = rootItem.rpcFileIndexes
    }
    
    
    /// Sort all folders/files included in directory
    public func sort() {
        rootItem.sort()
    }
    
    public var sortPredicate: ((FSItem,FSItem)->Bool)? {
        get {
            return rootItem.sortPredicate
        }
        set {
            //self.rootItem.objectWillChange.send()
            rootItem.sortPredicate = newValue
        }
    }
    
    
    /// Return File item positioned in a particular IndexPath position
    ///
    /// - parameter indexPath: Array of indexPath of file item
    /// return: the file Item positioned at the IndexPath
    public func item(atIndexPath indexPath: IndexPath) -> FSItem? {
        var indexPath = indexPath
        var item = rootItem
        guard !indexPath.isEmpty else { return nil}
        while let index = indexPath.popFirst() {
            item = item.items![index]
        }
        return item
    }
    
    
    public func childIndexes(for item: FSItem) -> [IndexPath] {
        var indexes = [IndexPath]()
        for childItem in item.items ?? [] {
            if childItem.isFolder {
                indexes.append(contentsOf: childIndexes(for: childItem))
            }
            indexes.append(childItem.indexPath)
        }
        return indexes
    }
    
    
    public func item(at rpcIndex: Int) -> FSItem? {
        return rpcIndexFiles[rpcIndex]
    }
    
    public var rpcIndexesUnwanted: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            !item.isWanted
        }
        return Array(indexes.keys)
    }
    
    public var rpcIndexesLowPriority: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            item.priority == .low
        }
        return Array(indexes.keys)
    }
    
    public var rpcIndexesHighPriority: [Int] {
        let indexes = rpcIndexFiles.filter { (index, item) in
            item.priority == .high
        }
        return Array(indexes.keys)
    }
    
    public func updateFSDir(usingStats fileStats:[JSONObject]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent?.isWanted)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent?.priorityInteger)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for:\.parent?.bytesCompletedString)
                //self.rpcIndexFiles[i]?.parent?.objectWillChange.send()
                self.rpcIndexFiles[i]?.bytesCompleted = (file[JSONKeys.bytesCompleted] as! Int)
                if self.rpcIndexFiles[i]?.isWanted != (file[JSONKeys.wanted] as! Bool) {
                    self.rpcIndexFiles[i]?.isWanted = file[JSONKeys.wanted] as! Bool
                }
                if self.rpcIndexFiles[i]?.priorityInteger != (file[JSONKeys.priority] as! Int) {
                    self.rpcIndexFiles[i]?.priorityInteger = file[JSONKeys.priority] as! Int
                }
            //rpcIndexFiles[i]?.parent?.didChangeValue(for: \.parent?.isWanted)
            //rpcIndexFiles[i]?.parent?.didChangeValue(for: \.parent?.priorityInteger)
            //rpcIndexFiles[i]?.parent?.didChangeValue(for: \.parent?.bytesCompletedString)
        }
    }
    
    public func updateFSDir(usingStats fileStats:[FileStat]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent.isWanted)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent.priorityInteger)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for:\.parent.bytesCompletedString)
                //self.rpcIndexFiles[i]?.parent?.objectWillChange.send()
                self.rpcIndexFiles[i]?.bytesCompleted = file.bytesCompleted
                if self.rpcIndexFiles[i]?.isWanted != file.wanted {
                    self.rpcIndexFiles[i]?.isWanted = file.wanted
                }
                if  self.rpcIndexFiles[i]?.priorityInteger != file.priority {
                    self.rpcIndexFiles[i]?.priorityInteger = file.priority
                }
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent?.isWanted)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for: \.parent?.priorityInteger)
            //rpcIndexFiles[i]?.parent?.willChangeValue(for:\.parent?.bytesCompletedString)
        }
    }
    
    public func updateFSDir(with fsDir: FSDirectory) {
        if fsDir.id == self.id {
            self.rootItem.items = fsDir.rootItem.items
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
            
            levelItem = levelItem.add(withName: itemName, isFolder: isFolder)
            
            // cache folder item
            if isFolder {
                folderItems[cPath] = levelItem
                levelItem.fullName = (cPath as NSString).substring(to: cPath.count - 1)
                
                //os_log(@"%@", levelItem.fullName);
            } else {
                levelItem.rpcIndex = rpcIndex
            }
        }
        rpcIndexFiles = rootItem.rpcFileIndexes
        return levelItem
    }
    
    
    
}
