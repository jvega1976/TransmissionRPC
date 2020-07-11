//
//  FSItem.swift
//  TransmissionRPC
//
//  Created by  on 7/21/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation
import Combine

public let FSITEM_INDEXNOTFOUND = -1

public enum FilePriority: Int, Codable {
    case low = 0
    case normal = 1 /* since NORMAL is 0, memset initializes nicely */
    case high = 2
}

// MARK: - Class FSItem
public final class FSItem: NSObject, ObservableObject, Identifiable {
    
    public var id: String {
        return fullName
    }
    
    /// Returns YES if this is a folder
    public var isFolder: Bool {
        return items != nil
    }
    
    /// File name including path
    @Published public var fullName = ""
    
    /// File folder name (w/o starting paths)
    @Published public var name = ""
    
    
    @Published public var bytesCompleted: Int  = 0 {
        didSet {
            if !isFolder && size > 0 {
                self.downloadProgress = Float(bytesCompleted) / Float(size)
            }
            self.bytesCompletedString = ByteCountFormatter.formatByteCount(bytesCompleted)
            guard let parent = self.parent else { return }
            parent.bytesCompleted = parent.fsItems!.reduce(0, { x, y in
                x + y.bytesCompleted })
        }
    }
  
    /// Bytes downloaded - string representation
    @Published public var bytesCompletedString: String = ""
    
    
    /// Total size of file/folder
    @Published public var size: Int = 0 {
        didSet {
            if size > 0 {
                downloadProgress = Float(bytesCompleted) / Float(size)
            }
            self.sizeString = ByteCountFormatter.formatByteCount(size)
            guard let parent = self.parent else { return }
            parent.size = parent.fsItems!.reduce(0, { size, item in
                size + (item.isFolder || item.isWanted ? item.size : 0) })
        }
    }
    
    /// Total size of file/folder - string representation
    @Published public var sizeString: String = ""

    
    /// Returns YES if this file/folder Wanted
    
    @Published public var isWanted: Bool = true {
        didSet {
            if let parent = self.parent {
                //return !items!.contains(where: { !$0.isWanted })
                parent.isWanted = parent.items!.reduce(true, { isWanted, item in
                    return isWanted && item.isWanted
                })
            }
            if !self.isFolder,
                let parent = self.parent {
                    parent.size = parent.items!.reduce(0, { size, item in
                        size + (item.isFolder || item.isWanted ? item.size : 0)
                })
            }
        }
    }
    
    /// Priority of this file/folder
    
    @Published public var priority: FilePriority = .normal {
        didSet {
            if self.priorityInteger != self.priority.rawValue {
                self.priorityInteger = self.priority.rawValue
            }
            guard let parent = self.parent else { return }
            parent.priority = parent.fsItems!.contains(where: {$0.priority == .low}) ? .low : (parent.fsItems!.contains(where: {$0.priority == .high}) ? .high : .normal)
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
    
    @Published public var priorityInteger: Int = 0 {
        didSet {
            guard let priority = FilePriority(rawValue: self.priorityInteger) ,
                  self.priority != priority  else { return }
            self.priority = priority
        }
    }

    
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
    public func add(withName name: String, isFolder: Bool) -> FSItem {
        let item = FSItem(name: name, isFolder: isFolder)
        
        item.level = self.level + 1
        item.parent = self
        fsItems!.append(item)
        items!.append(item)
        return item
    }

    
    public init(name: String, isFolder: Bool) {
        super.init()
        self.level = 0
        self.name = name
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
        self.name = ""
        self.size = 0
        self.bytesCompleted = 0
        self.sizeString = ""
        self.isWanted = true
        if isFolder {
            fsItems = []
            items = []
        }
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
        
        var newItem: FSItem
        if let item = self.fsItems!.first(where: {$0.name == itemName}) {
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
