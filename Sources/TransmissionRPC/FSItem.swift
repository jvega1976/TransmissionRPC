//
//  FSItem.swift
//  TransmissionRPC
//
//  Created by  on 7/21/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine

public let FilePriorityLow = 0
public let FilePriorityNormal = 1 /* since NORMAL is 0, memset initializes nicely */
public let FilePriorityHigh = 2

public typealias FilePriority = Int


// MARK: - Class FSItem
public final class FSItem: NSObject, ObservableObject, Identifiable, Codable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case fullName
        case bytesCompleted
        case size
        case isWanted
        case priority
        case downloadProgress
        case rpcIndex
        case fsItems
        case items
        case level
        case parent
    }
    
    
    @Published public var id: String = ""
    
    /// Returns YES if this is a folder
    public var isFolder: Bool {
        return items != nil
    }
    
    /// File name including path
    @Published public var fullName = "" {
        didSet {
            self.name = (self.fullName as NSString).lastPathComponent
        }
    }
    
    /// File folder name (w/o starting paths)
    @Published public var name = ""
    
    @Published public var bytesCompleted: Double  = 0 {
        didSet {
            if !isFolder && size > 0 {
                self.downloadProgress = bytesCompleted/size
            }
            self.bytesCompletedString = ByteCountFormatter.formatByteCount(Int(bytesCompleted))
            guard let parent = self.parent else { return }
            parent.bytesCompleted = parent.fsItems!.reduce(0, { x, y in
                x + y.bytesCompleted })
        }
    }
  
    /// Bytes downloaded - string representation
    @Published public var bytesCompletedString: String = ""
    
    
    /// Total size of file/folder
    @Published public var size: Double = 0 {
        didSet {
            if size > 0 {
                downloadProgress = bytesCompleted/size
            }
            self.sizeString = ByteCountFormatter.formatByteCount(Int(size))
            guard let parent = self.parent else { return }
            parent.size = parent.fsItems!.reduce(0, { size, item in
                size + (item.isFolder || (item.isWanted ?? false) ? item.size : 0) })
        }
    }
    
    /// Total size of file/folder - string representation
    @Published public var sizeString: String = ""

    
    /// Returns YES if this file/folder Wanted
    
    @Published public var isWanted: Bool? = true {
        didSet {
            if let parent = self.parent {
                //return !items!.contains(where: { !$0.isWanted })
                if parent.items!.allSatisfy({ item in
                    item.isWanted ?? false
                }) {
                    self.parent?.isWanted = true
                } else if parent.items!.allSatisfy({ item in
                    !(item.isWanted ?? true)
                }) {
                    self.parent?.isWanted = false
                } else {
                    self.parent?.isWanted = nil
                }
            }
            if !self.isFolder,
                let parent = self.parent {
                    parent.size = parent.items!.reduce(0, { size, item in
                        size + (item.isFolder || (item.isWanted ?? false) ? item.size : 0)
                })
            }
        }
    }
    
    /// Priority of this file/folder
    
    @Published public var priority: FilePriority = FilePriorityNormal
    
    public var priorityDescription: String {
        switch priority {
        case FilePriorityLow:
            return "Low"
        case FilePriorityNormal:
            return "Normal"
        case FilePriorityHigh:
            return "High"
        default:
            return "Invalid"
        }
    }
        

    /// Download progress for file/folder (0 ... 1)
    @Published public var downloadProgress: Double = 0 {
        didSet {
            self.downloadProgressString = (downloadProgress * 100.0).truncatingRemainder(dividingBy: 1.0)  == 0 ? String(format: "%03.0f%%", downloadProgress * 100.0) : String(format: "%03.2f%%", downloadProgress * 100.0)
        }
    }
    
    /// Download progress - string representation (0 .. 100%)
    @Published public var downloadProgressString: String = ""
    
    /// File index in RPC results (valid only for files)
    @Published public var rpcIndex:Int = 0
    
    /// Holds subfolders/files - if this is a Folder
    fileprivate var fsItems: Array<FSItem>? = nil
    
    @Published public var items: Array<FSItem>? = nil
    

    /// Holds level of this file/folder
    @Published public var level: Int = 0
    

    /// Returns RPC file indexes
    
    public var rpcFileIndexes: [Int: FSItem] {
        var rpcFileIndexes = [Int: FSItem]()
        if isFolder {
            for i in fsItems ?? [] {
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
            for i in fsItems ?? [] {
                indexes.append(contentsOf: i.rpcIndexes)
            }
        }
        else {
            indexes.append(self.rpcIndex)
        }
        return indexes
    }
    
    /// Holds parent reference
    @Published public var parent: FSItem? = nil
    
    /// Add new item to folder item
    public func add(withFullName name: String, isFolder: Bool) -> FSItem {
        let item = FSItem(fullName: name, isFolder: isFolder)
        item.level = self.level + 1
        item.parent = self
        fsItems!.append(item)
        items!.append(item)
        return item
    }

    
    public init(fullName: String, isFolder: Bool) {
        super.init()
        self.level = 0
        self.fullName = fullName
        self.id = fullName
        self.size = 0
        self.sizeString = ""
        self.bytesCompleted = 0
        self.isWanted = true
        if isFolder {
            fsItems = []
            items = []
        }
        else {
            fsItems = nil
            items = nil
        }
    }
    
    public override init() {
        super.init()
        self.level = 0
        self.fullName = ""
        self.id = ""
        self.size = 0
        self.bytesCompleted = 0
        self.sizeString = ""
        self.isWanted = true
        if isFolder {
            fsItems = []
            items = []
        }
    }
    
    public init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        fullName = try values.decode(String.self, forKey: .fullName)
        bytesCompleted = try values.decode(Double.self, forKey: .bytesCompleted)
        size = try values.decode(Double.self, forKey: .size)
        isWanted = try values.decode(Bool.self, forKey: .isWanted)
        priority = try values.decode(FilePriority.self, forKey: .priority)
        downloadProgress = try values.decode(Double.self, forKey: .downloadProgress)
        rpcIndex = try values.decode(Int.self, forKey: .rpcIndex)
        fsItems = try values.decode([FSItem].self, forKey: .fsItems)
        items = try values.decode([FSItem].self, forKey: .items)
        level = try values.decode(Int.self, forKey: .level)
        parent = try values.decode(FSItem.self, forKey: .parent)
    }
    
    public func update(withFSItem item: FSItem) {
        self.fullName = item.fullName
        self.size = item.size
        self.bytesCompleted = item.bytesCompleted
        self.priority = item.priority
        self.isWanted = item.isWanted
        self.items = item.items
        self.fsItems = item.fsItems
    }

    func sort(by sortPredicate: (FSItem,FSItem)->Bool) {
        if self.isFolder {
            items!.forEach {item in
                item.sort(by: sortPredicate)
            }
            items!.sort(by: sortPredicate)
        }
    }
    
    func filter(_ filterPredicate: ((FSItem)->Bool)?) {
        if self.isFolder {
            items!.forEach {item in
                item.filter(filterPredicate)
            }
            if let filterPredicate = filterPredicate {
                items = fsItems!.filter(filterPredicate)
            } else {
                items = fsItems
            }
        }
    }
    
    func findItem(withName name: String) -> FSItem? {
        if !self.isFolder && self.fullName == name {
            return self
        } else if self.isFolder {
            for item in items ?? [] {
                if let found = item.findItem(withName: name) {
                    return found
                }
            }
        }
        return nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(bytesCompleted, forKey: .bytesCompleted)
        try container.encode(size, forKey: .size)
        try container.encode(isWanted, forKey: .isWanted)
        try container.encode(priority, forKey: .priority)
        try container.encode(downloadProgress, forKey: .downloadProgress)
        try container.encode(rpcIndex, forKey: .rpcIndex)
        try container.encode(fsItems, forKey: .fsItems)
        try container.encode(items, forKey: .items)
        try container.encode(level, forKey: .level)
        try container.encode(parent, forKey: .parent)
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
        return lhs.fullName == rhs.fullName && lhs.isFolder == rhs.isFolder
    }
    
    public static func != (lhs: FSItem, rhs: FSItem) -> Bool {
        return lhs.fullName != rhs.fullName
    }
    
   override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FSItem else { return false}
        return self.fullName == object.fullName && self.isFolder == object.isFolder
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
        let fullName = isFolder ? (self.fullName + (!self.fullName.isEmpty ? "/" : "") + itemName) : fileInfo[JSONKeys.name] as! String
        var newItem: FSItem
        if let item = self.fsItems!.first(where: {$0.fullName == fullName}) {
           newItem = item
        }
        else {
            newItem = self.add(withFullName: fullName, isFolder: isFolder)
        }
        
        if newItem.isFolder {
            fileInfo[TR_ARG_FIELDS_FILE_PATHCOMPONENTS] = pathComponents
            newItem.addPathComponents(withJSONFileInfo: &fileInfo, jsonFileStatInfo: fileStatInfo, rpcIndex: rpcIndex)
        } else {
            newItem.rpcIndex = rpcIndex
            let bytesCompleted = fileInfo[JSONKeys.bytesCompleted] as! Double
            let size = fileInfo[JSONKeys.length] as! Double
            newItem.size = size
            newItem.bytesCompleted = bytesCompleted
            newItem.isWanted = fileStatInfo[JSONKeys.wanted] as? Bool
            newItem.priority = fileStatInfo[JSONKeys.priority] as? FilePriority ?? FilePriorityNormal
        }
    }
    
    public func addPathComponents(withFile fileInfo: inout File, andStat fileStatInfo: FileStat, rpcIndex: Int) {
        // add all components to the tree (from root){
        let itemName = fileInfo.pathComponents.removeFirst()
        
        // last item in array is file, the others - folders
        let isFolder = !fileInfo.pathComponents.isEmpty
        let fullName = isFolder ? (self.fullName + (!self.fullName.isEmpty ? "/" : "") + itemName) : fileInfo.name
        var newItem: FSItem
        if let item = self.fsItems!.first(where: {$0.fullName == fullName}) {
           newItem = item
        }
        else {
            newItem = self.add(withFullName: fullName, isFolder: isFolder)
        }
        
        if newItem.isFolder {
            newItem.addPathComponents(withFile: &fileInfo, andStat: fileStatInfo, rpcIndex: rpcIndex)
        } else {
            newItem.rpcIndex = rpcIndex
            newItem.size = fileInfo.length
            newItem.bytesCompleted = fileStatInfo.bytesCompleted
            newItem.isWanted = fileStatInfo.wanted
            newItem.priority = fileStatInfo.priority
        }
    }
}
