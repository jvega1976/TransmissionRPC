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

#if os(iOS)
import UIKit
#else
import AppKit
#endif
import Foundation

fileprivate let PATH_SPLITTER_STRING = "/"
let TR_ARG_FIELDS_FILE_PATHCOMPONENTS = "pathComponents"

//MARK: - FSDirectory structure

public struct FSDirectory {
    
    private var root: FSItem!
    private var folderItems = [AnyHashable : Any]()
    private var rpcIndexFiles = [Int: FSItem]()
    
    /// Get count of items in directory
    private var _count = -1
    public var count: Int {
        mutating get {
            if _count == -1 {
                _count = root.filesCount
            }
            return _count
        }
    }
    
    
    /// Get root FSItem
    public var rootItem: FSItem? {
        return root
    }
    
    /// Initializer
    public init() {
        self.root = FSItem(name: "", isFolder: true) // init root element (always folder)
        self.root.indexPath = IndexPath()
        self.folderItems = [:]
    }
    
    /// Initializer, filling Directory items with JSON objects content
    ///
    /// - parameter files: Array of JSON objects containing file properties
    /// - parameter fileStats: Array of JSON objects containing file statistics
    /// return: A new FSDirectory object containing all Files for one particular Torrent
    
    public init(withJSONFileInfo files: [JSONObject], jsonFileStatInfo fileStats:[JSONObject]) {
        self.init()
        for i in 0..<files.count {
            var file = files[i]
            let fullName = file[JSONKeys.name] as! String
            let pathComponents = fullName.components(separatedBy: PATH_SPLITTER_STRING)
            file[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] = pathComponents
            root.addPathComponents(withJSONFileInfo: &file, jsonFileStatInfo: fileStats[i], rpcIndex: i)
        }
        rpcIndexFiles = root.rpcFileIndexes
        root.sort()
        
    }
    
    
    /// Sort all folders/files included in directory
    public func sort() {
        root?.sort()
    }
    
    
    /// Return File item positioned in a particular IndexPath position
    ///
    /// - parameter indexPath: Array of indexPath of file item
    /// return: the file Item positioned at the IndexPath
    public func item(atIndexPath indexPath: IndexPath) -> FSItem? {
        var indexPath = indexPath
        guard var item = root else { return nil}
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
    
    public mutating func updateFSDir(usingStats fileStats:[JSONObject]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            rpcIndexFiles[i]?.bytesCompleted = (file[JSONKeys.bytesCompleted] as! Int)
            rpcIndexFiles[i]?.isWanted = file[JSONKeys.wanted] as! Bool
            rpcIndexFiles[i]?.priority = FilePriority(rawValue: (file[JSONKeys.priority] as! Int) + 1) ?? .normal
        }
    }
    
    public mutating func updateFSDir(usingStats fileStats:[FileStat]) {
        for i in 0..<fileStats.count {
            let file = fileStats[i]
            rpcIndexFiles[i]?.bytesCompleted = file.bytesCompleted
            rpcIndexFiles[i]?.isWanted = file.wanted
            rpcIndexFiles[i]?.priority = FilePriority(rawValue: file.priority + 1) ?? .normal
        }
    }
    
    
    public var description: String {
        return root!.description
    }
}


// MARK: - TorrentFile initializer extension

extension FSDirectory {
    
    /// add new item to directory with file path
    public mutating func addFilePath(_ path: String, andRpcIndex rpcIndex: Int) -> FSItem {
        // split the path string
        let pathComponents = path.components(separatedBy: PATH_SPLITTER_STRING)
        
        return addPathComonents(pathComponents, andRpcIndex: rpcIndex)
    }
    
    /// add new item to directory with separated file path
    public mutating func addPathComonents(_ pathComponents: [String], andRpcIndex rpcIndex: Int) -> FSItem {
        // add all components to the tree (from root)
        var levelItem = root
        
        let c = pathComponents.count
        
        var cPath = ""
        
        for level in 0..<c {
            let itemName = pathComponents[level]
            
            // last item in array is file, the others - folders
            let isFolder = level != (c - 1)
            
            cPath += itemName
            cPath += "/"
            
            if isFolder  && folderItems[cPath] != nil {
                levelItem = folderItems[cPath] as? FSItem
                continue
            }
            
            levelItem = levelItem!.add(withName: itemName, isFolder: isFolder)
            
            // cache folder item
            if isFolder {
                folderItems[cPath] = levelItem
                levelItem!.fullName = (cPath as NSString).substring(to: cPath.count - 1)
                
                //os_log(@"%@", levelItem.fullName);
            } else {
                levelItem!.rpcIndex = rpcIndex
            }
        }
        rpcIndexFiles = root.rpcFileIndexes
        return levelItem!
    }
    
    
}
