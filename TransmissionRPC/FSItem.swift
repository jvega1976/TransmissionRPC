//
//  FSItem.swift
//  TransmissionRPC
//
//  Created by  on 7/21/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

public let FSITEM_INDEXNOTFOUND = -1

public enum FilePriority: Int, Codable {
    case low = 0
    case normal = 1 /* since NORMAL is 0, memset initializes nicely */
    case high = 2
}

// MARK: - Class FSItem
public class FSItem: NSObject {
    
    /// flag indicates that all files withing this folder is wanted
    public var allFilesWanted = false
    
    /// Returns YES if this is a folder
    public var isFolder = false
    
    public var waitingForWantedUpdate: Bool = false
    
    /// Returns YES if folder is collapsed
    public var isCollapsed = false
    
    /// Returns YES if this is a file
    public var isFile: Bool {
        return !isFolder
    }
    
    /// File name including path
    public var fullName = ""
    
    /// File folder name (w/o starting paths)
    public var name = ""
    
    ///IndexPath representing the location of the item location in the Directory tree
    public var indexPath: IndexPath!
    
    /// Bytes downloaded
    private var _bytesCompleted: Int = 0 {
        didSet {
            if size > 0 {
                downloadProgress = Float(_bytesCompleted) / Float(size)
            }
        }
    }
    
    public var bytesCompleted: Int! {
       set(newBytesCompleted) {
            if isFile {
                _bytesCompleted = newBytesCompleted
            }
        }
        get {
            if isFolder {
                _bytesCompleted = items!.reduce(0, { x, y in
                    x + y.bytesCompleted
                })

            }
            return _bytesCompleted
        }
    }
    
    /// Bytes downloaded - string representation
    public var bytesCompletedString: String {
        return formatByteCount(self.bytesCompleted)
    }
    
    /// Total size of file/folder
    public var size: Int!  {
        didSet {
            if size > 0 {
                downloadProgress = Float(bytesCompleted) / Float(size)
            }
        }
    }
    
    /// Total size of file/folder - string representation
    public var sizeString: String {
        return formatByteCount(size)
    }
    
    /// Returns YES if this file/folder Wanted
    private var _isWanted: Bool = true
    public var isWanted: Bool {
        set(newWanted) {
            if isFile {
                _isWanted = newWanted
            }
        }
        get {
            if isFolder {
                _isWanted = !items!.contains(where: { !$0.isWanted })
            }
            return _isWanted
        }
    }
    
    /// Priority of this file/folder
    private var _priority: FilePriority! = .normal
    public var priority: FilePriority! {
        set(newPriority) {
            if isFile {
                _priority = newPriority
            }
        }
        get {
            if isFolder {
                _priority = items!.contains(where: {$0.priority == .low}) ? .low : ( items!.contains(where: {$0.priority == .high}) ? .high : .normal)
            }
            return _priority
        }
    }
    
    public var priorityString: String {
        switch priority {
            case .low:
                return "Low"
            case .normal:
                return "Normal"
            case.high:
                return "High"
            case .none:
                return "Normal"
        }
        
    }
    
    /// Download progress for file/folder (0 ... 1)
    public var downloadProgress: Float = 0
    
    /// Download progress - string representation (0 .. 100%)
    public var downloadProgressString: String {
        return String(format: "%03.2f%%", downloadProgress * 100.0)
    }
    
    /// File index in RPC results (valid only for files)
    public var rpcIndex:Int = 0
    
    /// Holds subfolders/files - if this is a Folder
    public var items: [FSItem]? = nil
    
    /// Holds level of this file/folder
    public var level: Int = 0
    
    /// Get count of files in this folder
    private var _filesCount: Int = -1
    public var filesCount: Int {
        if _filesCount == -1 {
            if !isFolder {
                _filesCount = 1
            }  else {
                _filesCount = items!.reduce(0, { x , y in
                    x + y.filesCount
                })
            }
        }
        return _filesCount
    }
    
    /// Get count of subfolders in this folder
    private(set) var subfoldersCount = 0
    
    
    /// Returns RPC file indexes
    
    public var rpcFileIndexes: [Int: FSItem] {
        var indexes = [Int: FSItem]()
        if isFolder {
            for i in items! {
                if i.isFile {
                    indexes[i.rpcIndex] = i
                } else {
                    indexes.merge(i.rpcFileIndexes) { (current, _) in current }
                }
            }
        }
        return indexes
    }
    
    
    public var rpcIndexes: [Int] {
        var indexes = [Int]()
        if isFolder {
            for i in items! {
                indexes.append(contentsOf: i.rpcIndexes)
            }
        }
        else {
            indexes.append(self.rpcIndex)
        }
        return indexes
    }
    
    /// Returns RPC wanted file indexes
    public var rpcFileIndexesWanted: [Int]? {
        var indexes: [Int]? = nil
        if isFolder {
            indexes = []
            for i in items! {
                if i.isFile && i.isWanted {
                    indexes!.append(i.rpcIndex)
                } else {
                    indexes = indexes! + (i.rpcFileIndexesWanted ?? [])
                }
            }
        }
        return indexes
    }
    /// Returns RPC unwanted file indexes
    
    public var rpcFileIndexesUnwanted: [Int]? {
        var indexes: [Int]? = nil
        if isFolder {
            indexes = []
            for i in items! {
                if i.isFile && !i.isWanted {
                    indexes!.append(i.rpcIndex)
                } else {
                    indexes = indexes! + (i.rpcFileIndexesUnwanted ?? [])
                }
            }
        }
        return indexes
    }

    public var rpcFileIndexesHighPriority: [Int]? {
        var indexes: [Int]? = nil
    
        if isFolder {
            indexes = []
            for i in items! {
                if i.isFile && (i.priority == .high) {
                    indexes!.append(i.rpcIndex)
                } else {
                    indexes!.append(contentsOf: (i.rpcFileIndexesHighPriority ?? []))
                }
            }
        }
        return indexes
    }
    
    public var rpcFileIndexesLowPriority: [Int]? {
        var indexes: [Int]? = nil
        if isFolder {
            indexes = []
            for i in items! {
                if i.isFile && (i.priority == .low) {
                    indexes!.append(i.rpcIndex)
                } else {
                    indexes!.append(contentsOf: i.rpcFileIndexesLowPriority ?? [])
                }
            }
        }
        return indexes
    }
    
    /// Holds parent reference
    weak public var parent: FSItem?
    
    /// Add new item to folder item
    func add(withName name: String, isFolder: Bool) -> FSItem {
        let item = FSItem(name: name, isFolder: isFolder)
        
        item.level = self.level + 1
        item.parent = self
        item.indexPath = self.indexPath.appending(self.items!.count)
        items!.append(item)
        
        return item
    }
    
    init(name: String, isFolder: Bool) {
        super.init()
        self.level = 0
        self.name = name
        self.isFolder = isFolder
        self.size = 0
        self.bytesCompleted = 0
        self.isWanted = true
        
        if isFolder {
            items = []
        }
    }
    
    class func keyPathsForValuesAffectingPriorityString() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["priority"])
    }
    
    
    // add item to children, if it is already exists
    // return existing item
    open override var description: String {
        var spaces = ""
        for _ in 0..<level {
            spaces += "  "
        }
        
        if !isFolder {
            return "\(spaces)\(name)!\n"
        }
        
        var s = "\(spaces)/\(name)\n"
        
        if !isCollapsed {
            for item in items ?? []  {
                s += item.description
            }
        }
        
        return s
    }
    
    
    func sort() {
        if isFolder {
            for item in items!.filter({ $0.isFolder }) {
                item.sort()
            }
            items!.sort()
        }
    }
    
}

// MARK: - Comparable Protocol extension

extension FSItem: Comparable {
    
    public static func < (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.name < rhs.name
        }
        else if lhs.isFolder && rhs.isFile  {
            return true
        }
        else if lhs.isFile && rhs.isFolder {
            return false
        }
        return lhs.name < rhs.name
    }
    
    public static func <= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.name <= rhs.name
        }
        else if lhs.isFolder && rhs.isFile  {
            return true
        }
        else if lhs.isFile && rhs.isFolder {
            return false
        }
        return lhs.name <= rhs.name
    }
    
    public static func > (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.name > rhs.name
        }
        else if lhs.isFolder && rhs.isFile  {
            return false
        }
        else if lhs.isFile && rhs.isFolder {
            return true
        }
        return lhs.name > rhs.name
    }
    
    public static func >= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.name >= rhs.name
        }
        else if lhs.isFolder && rhs.isFile  {
            return false
        }
        else if lhs.isFile && rhs.isFolder {
            return true
        }
        return lhs.name >= rhs.name
    }
    
    public static func == (lhs: FSItem, rhs: FSItem) -> Bool {
        return lhs.name == rhs.name
    }
    
}

//MARK: - Extension to create a new FSItem, based in a Bencoded Serialized object

extension FSItem {
    
    public func addPathComponents(withJSONFileInfo  fileInfo: inout [String : Any], jsonFileStatInfo fileStatInfo: [String : Any], rpcIndex: Int) {
        // add all components to the tree (from root){
        var pathComponents = fileInfo[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] as! [String]

        let itemName = pathComponents.removeFirst()
        
        // last item in array is file, the others - folders
        let isFolder = !pathComponents.isEmpty
        
        var newItem: FSItem
        if let item = self.items?.first(where: {$0.name == itemName}) {
           newItem = item
        }
        else {
            newItem = self.add(withName: itemName, isFolder: isFolder)
        }
        
        if newItem.isFolder {
           fileInfo[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] = pathComponents
           newItem.addPathComponents(withJSONFileInfo: &fileInfo, jsonFileStatInfo: fileStatInfo, rpcIndex: rpcIndex)
/*            if newItem.parent!.fullName != "" {
                newItem.fullName = newItem.parent!.fullName + "/" + newItem.name
            }
            else {
                newItem.fullName = newItem.name
            }*/
        } else {
            newItem.fullName = fileInfo[JSONKeys.name] as! String
            newItem.rpcIndex = rpcIndex
            let bytesCompleted = fileInfo[JSONKeys.bytesCompleted] as! Int
            let size = fileInfo[JSONKeys.length] as! Int
        
            newItem.size = size
            newItem.bytesCompleted = bytesCompleted
            newItem.isWanted = fileStatInfo[JSONKeys.wanted] as! Bool
            newItem.priority = FilePriority(rawValue: (fileStatInfo[JSONKeys.priority] as? Int ?? 0) + 1) ?? .normal
        }
        self.size += newItem.size
    }
}
