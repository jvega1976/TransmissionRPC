//
//  FSItem.swift
//  TransmissionRPC
//
//  Created by  on 7/21/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine
import Outline

public let FSITEM_INDEXNOTFOUND = -1

public enum FilePriority: Int, Codable {
    case low = 0
    case normal = 1 /* since NORMAL is 0, memset initializes nicely */
    case high = 2
}

// MARK: - Class FSItem
public final class FSItem: NSObject, ObservableObject, OutlineData {
    
    
    public var isExpandable: Bool {
        get {
         return self.isFolder
        }
    }
    
    /// Returns YES if this is a folder
    @Published public var isFolder: Bool = false
    
    
    @Published public var filterPredicate: ((FSItem)->Bool)? {
        didSet {
            if self.isFolder {
                for file in self.fsItems {
                    file.filterPredicate = self.filterPredicate
                }
            }
        }
    }
    
    /// File name including path
    @Published public var fullName = ""
    
    /// File folder name (w/o starting paths)
    @Published public var name = "" {
        didSet {
            if let parent = self.parent {
                self.fullName = parent.fullName + "/" + self.name
            } else {
                self.fullName = self.name
            }
        }
    }
    
    ///IndexPath representing the location of the item location in the Directory tree
    @Published public var indexPath: IndexPath!
    
    /// Bytes downloaded
    private var _bytesCompleted: Int = 0 {
        didSet {
            if size > 0 {
                self.downloadProgress = Float(_bytesCompleted) / Float(size)
            }
             self.bytesCompletedString = ByteCountFormatter.formatByteCount(_bytesCompleted)
        }
    }
    
    public var bytesCompleted: Int  = 0 {
       didSet {
            if !isFolder {
                self._bytesCompleted = bytesCompleted
                self.parent?.recalculateBytesCompleted()
            }
        }
    }
    
    private func recalculateBytesCompleted() {
        self._bytesCompleted = fsItems.reduce(0, { x, y in
            x + y._bytesCompleted
        })
        self.parent?.recalculateBytesCompleted()
    }
    
    /// Bytes downloaded - string representation
    @Published public var bytesCompletedString: String = ""
    
    
    /// Total size of file/folder
    @Published public var size: Int = 0 {
        didSet {
            if size > 0 {
                downloadProgress = Float(_bytesCompleted) / Float(size)
            }
            self.sizeString = ByteCountFormatter.formatByteCount(size)
            if let parent = self.parent {
                parent.size = parent.items.reduce(0, { size, item in
                    size + (item.isFolder || item.isWanted ? item.size : 0)
                })
            }
        }
    }
    
    /// Total size of file/folder - string representation
    @Published public var sizeString: String = ""

    
    /// Returns YES if this file/folder Wanted
    
    @Published public var isWanted: Bool = true {
        didSet {
            if let parent = self.parent {
                //return !items!.contains(where: { !$0.isWanted })
                parent.isWanted = parent.items.reduce(true, { isWanted, item in
                    return isWanted && item.isWanted
                })
            }
            if !self.isFolder,
                let parent = self.parent {
                    parent.size = parent.items.reduce(0, { size, item in
                        size + (item.isFolder || item.isWanted ? item.size : 0)
                })
            }
        }
    }
    
    /// Priority of this file/folder
    private var _priority: FilePriority = .normal {
        didSet {
            self.priorityInteger = _priority.rawValue
        }
    }
    
    public var priority: FilePriority = .normal {
        didSet {
            if !isFolder {
                _priority = priority
            } else {
                _priority = fsItems.contains(where: {$0._priority == .low}) ? .low : ( fsItems.contains(where: {$0._priority == .high}) ? .high : .normal)
            }
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
        }
        
    }
    
    @Published public var priorityInteger: Int = 0 

    
    /// Download progress for file/folder (0 ... 1)
    @Published public var downloadProgress: Float = 0 {
        didSet {
            self.downloadProgressString = (downloadProgress * 100.0).truncatingRemainder(dividingBy: 1.0)  == 0 ? String(format: "%03.0f%%", downloadProgress * 100.0) : String(format: "%03.2f%%", downloadProgress * 100.0)
        }
    }
    
    /// Download progress - string representation (0 .. 100%)
    @Published public var downloadProgressString: String = ""
    
    /// File index in RPC results (valid only for files)
    @Published public var rpcIndex:Int = 0
    
    /// Holds subfolders/files - if this is a Folder
    private var fsItems: [FSItem] = [] {
        didSet {
            if filterPredicate != nil {
                let result = fsItems.filter({ $0.satisfyFilterPredicate })
                if !(result.isEmpty){
                    self.items = result
                } else {
                    if fsItems.contains(where: { item in item.isFolder}) {
                        self.items = fsItems
                    }
                    self.items = result
                }
            } else {
                self.items = fsItems
            }
        }
    }
    
    @Published public var items: [FSItem] = []
    
    /// Return File item positioned in a particular IndexPath position
    ///
    /// - parameter indexPath: Array of indexPath of file item
    /// return: the file Item positioned at the IndexPath
    public func item(atIndexPath indexPath: IndexPath) -> FSItem? {
        var indexPath = indexPath
        var item = self
        while let index = indexPath.popFirst() {
            item = item.items[index]
        }
        return item
        
    }
    
    
    func reindexChildren() {
        for (index,item) in fsItems.enumerated()  {
            item.indexPath = self.indexPath.appending(index)
        }
    }

    
    fileprivate var satisfyFilterPredicate: Bool {
        if !self.isFolder {
            return filterPredicate!(self)
        } else {
            return fsItems.reduce(false) { (result: Bool, item: FSItem) -> Bool in
                return result || item.satisfyFilterPredicate
            }
        }
    }
    
    /// Holds level of this file/folder
    @Published public var level: Int = 0
    
    /// Get count of files in this folder
    private var _totalFilesCount: Int = -1
    public var totalFilesCount: Int {
        if _totalFilesCount == -1 {
            if !isFolder {
                _totalFilesCount = 1
            }  else {
                _totalFilesCount = items.reduce(0, { x , y in
                    x + y.totalFilesCount
                })
            }
        }
        return _totalFilesCount
    }
    
    public var filesCount: Int {
        return items.count
    }
    
    
    
    /// Get count of subfolders in this folder
    private(set) var subfoldersCount = 0
    
    
    /// Returns RPC file indexes
    
    public var rpcFileIndexes: [Int: FSItem] {
        var rpcFileIndexes = [Int: FSItem]()
        if isFolder {
            for i in fsItems {
                if !(i.isFolder) {
                    rpcFileIndexes[i.rpcIndex] = i
                } else {
                    rpcFileIndexes.merge(i.rpcFileIndexes) { (current, _) in current }
                }
            }
        }
        return rpcFileIndexes
    }
    
    
    public var rpcIndexes: [Int] {
        var indexes = [Int]()
        if isFolder {
            for i in fsItems {
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
            for i in fsItems {
                if !i.isFolder && i.isWanted {
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
            for i in fsItems {
                if !i.isFolder && !i.isWanted {
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
            for i in fsItems {
                if !i.isFolder && (i.priority == .high) {
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
            for i in fsItems {
                if !i.isFolder && (i.priority == .low) {
                    indexes!.append(i.rpcIndex)
                } else {
                    indexes!.append(contentsOf: i.rpcFileIndexesLowPriority ?? [])
                }
            }
        }
        return indexes
    }
    
    /// Holds parent reference
    @Published public var parent: FSItem?
    
    /// Add new item to folder item
    public func add(withName name: String, isFolder: Bool) -> FSItem {
        let item = FSItem(name: name, isFolder: isFolder)
        
        item.level = self.level + 1
        item.parent = self
        item.indexPath = self.indexPath.appending(self.items.count)
        fsItems.append(item)
        return item
    }

    
    public init(name: String, isFolder: Bool) {
        super.init()
        self.level = 0
        self.name = name
        self.isFolder = isFolder
        self.size = 0
        self.sizeString = ""
        self.bytesCompleted = 0
        self.isWanted = true
        self.indexPath = IndexPath()
        if isFolder {
            items = []
        }
    }
    
    public override init() {
        super.init()
        self.level = 0
        self.name = ""
        self.isFolder = false
        self.size = 0
        self.bytesCompleted = 0
        self.sizeString = ""
        self.isWanted = true
        self.indexPath = IndexPath()
        if isFolder {
            items = []
        }
    }
    
    
    // add item to children, if it is already exists
    // return existing item
    /*public override var description: String {
        var spaces = ""
        for _ in 0..<level {
            spaces += "  "
        }
        
        if !isFolder {
            return "\(spaces)\(name)!\n"
        }
        
        var s = "\(spaces)/\(name)\n"
        
        if !isCollapsed {
            for item in items {
                s += item.description
            }
        }
        
        return s
    }*/
    
    public var sortPredicate: ((FSItem,FSItem)->Bool)? {
        didSet {
            self.sort()
            for file in self.fsItems {
                file.sortPredicate = self.sortPredicate
            }
//            self.items = self.fsItems
        }
    }
    
    
    func sort() {
        if self.isFolder {
            if sortPredicate != nil {
                fsItems.sort(by: sortPredicate!)
            } else {
                fsItems.sort()
            }
            reindexChildren()
        }
    }
    
}

// MARK: - Comparable Protocol extension

extension FSItem: Comparable {
    
    public static func < (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName < rhs.fullName
        }
        else if lhs.isFolder && !rhs.isFolder  {
            return true
        }
        else if !lhs.isFolder && rhs.isFolder {
            return false
        }
        return lhs.fullName < rhs.fullName
    }
    
    public static func <= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName <= rhs.fullName
        }
        else if lhs.isFolder && !rhs.isFolder  {
            return true
        }
        else if !lhs.isFolder && rhs.isFolder {
            return false
        }
        return lhs.fullName <= rhs.fullName
    }
    
    public static func > (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName > rhs.fullName
        }
        else if lhs.isFolder && !rhs.isFolder  {
            return false
        }
        else if !lhs.isFolder && rhs.isFolder {
            return true
        }
        return lhs.fullName > rhs.fullName
    }
    
    public static func >= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName >= rhs.fullName
        }
        else if lhs.isFolder && !rhs.isFolder  {
            return false
        }
        else if !lhs.isFolder && rhs.isFolder {
            return true
        }
        return lhs.fullName >= rhs.fullName
    }
    
    public static func == (lhs: FSItem, rhs: FSItem) -> Bool {
        return lhs.fullName == rhs.fullName
    }
    
    public static func != (lhs: FSItem, rhs: FSItem) -> Bool {
        return lhs.fullName != rhs.fullName
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        return (object as? FSItem)?.fullName == self.fullName
    }
    
    #if os(macOS)
    override public func isEqual(to object: Any?) -> Bool {
        return (object as? FSItem)?.fullName == self.fullName
    }

    override public func isNotEqual(to object: Any?) -> Bool {
        return (object as? FSItem)?.fullName != self.fullName
    }
    #endif

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
        if let item = self.fsItems.first(where: {$0.name == itemName}) {
           newItem = item
        }
        else {
            newItem = self.add(withName: itemName, isFolder: isFolder)
        }
        
        if newItem.isFolder {
            fileInfo[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] = pathComponents
            newItem.fullName = (newItem.parent?.fullName ?? "") + (!(newItem.parent?.fullName.isEmpty ?? true) ? "/" : "") + newItem.name
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
            newItem.priorityInteger = fileStatInfo[JSONKeys.priority] as? Int ?? 0
        }
    }
}
