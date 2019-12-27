//
//  FSItem.swift
//  TransmissionRPC
//
//  Created by  on 7/21/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

public let FSITEM_INDEXNOTFOUND = -1

@objc public enum FilePriority: Int, Codable {
    case low = 0
    case normal = 1 /* since NORMAL is 0, memset initializes nicely */
    case high = 2
}

// MARK: - Class FSItem
@objcMembers open class FSItem: NSObject {
    
    /// flag indicates that all files withing this folder is wanted
    public var allFilesWanted = false
    
    /// Returns YES if this is a folder
    public var isFolder = false
    
    public var waitingForWantedUpdate: Bool = false
    
    /// Returns YES if folder is collapsed
    public var isCollapsed = false
    
    /// Returns YES if this is a file
    @objc dynamic public var isFile: Bool {
        return !isFolder
    }
    
    class func keyPathsForValuesAffectingIsFile() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["isFolder"])
    }
    
    public var filterPredicate: ((FSItem)->Bool)? {
        didSet {
            if self.isFolder {
                for file in self._items! {
                    file.filterPredicate = self.filterPredicate
                }
            }
        }
    }
    
    /// File name including path
    public var fullName = ""
    
    /// File folder name (w/o starting paths)
    public var name = ""
    
    ///IndexPath representing the location of the item location in the Directory tree
    public var indexPath: IndexPath!
    
    /// Bytes downloaded
    @objc dynamic private var _bytesCompleted: Int = 0 {
        didSet {
            if size > 0 {
                downloadProgress = Float(_bytesCompleted) / Float(size)
            }
        }
    }
    
    @objc dynamic public var bytesCompleted: Int {
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
    @objc dynamic public var bytesCompletedString: String {
        return formatByteCount(self.bytesCompleted)
    }
    
    class func keyPathsForValuesAffectingBytesCompletedString() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["bytesCompleted"])
    }
    
    
    /// Total size of file/folder
    @objc dynamic public var size: Int = 0 {
        didSet {
            if size > 0 {
                downloadProgress = Float(bytesCompleted) / Float(size)
            }
        }
    }
    
    /// Total size of file/folder - string representation
    @objc dynamic public var sizeString: String {
        return formatByteCount(size)
    }
    
    class func keyPathsForValuesAffectingSizeString() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["size"])
    }
    
    
    /// Returns YES if this file/folder Wanted
    @objc dynamic private var _isWanted: Bool = true
    @objc dynamic public var isWanted: Bool {
        set(newWanted) {
            if isFile {
                _isWanted = newWanted
            }
        }
        get {
            if isFolder {
                //return !items!.contains(where: { !$0.isWanted })
                return items!.reduce(true) { (prev, item) -> Bool in
                    return prev && item.isWanted
                }
            }
            return _isWanted
        }
    }
    
    class func keyPathsForValuesAffectingIsWanted() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["_isWanted"])
    }
    
    /// Priority of this file/folder
    @objc dynamic private var _priority: FilePriority = .normal
    @objc dynamic public var priority: FilePriority {
        set(newPriority) {
            if isFile {
                _priority = newPriority
            }
        }
        get {
            if isFolder {
                return items!.contains(where: {$0.priority == .low}) ? .low : ( items!.contains(where: {$0.priority == .high}) ? .high : .normal)
            }
            return _priority
        }
    }
    
    class func keyPathsForValuesAffectingPriority() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["_priority"])
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
    
    @objc dynamic public var priorityInteger: Int {
        set {
            if isFile {
                _priority = FilePriority(rawValue: newValue) ?? .normal
            }
        }
        get {
            return self.priority.rawValue
        }
    }
    
    class func keyPathsForValuesAffectingPriorityInteger() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["priority"])
    }
    
    /// Download progress for file/folder (0 ... 1)
    @objc dynamic public var downloadProgress: Float = 0
    
    /// Download progress - string representation (0 .. 100%)
    @objc dynamic public var downloadProgressString: String {
        return String(format: "%03.2f%%", downloadProgress * 100.0)
    }
    
    /// File index in RPC results (valid only for files)
    public var rpcIndex:Int = 0
    
    /// Holds subfolders/files - if this is a Folder
    private var _items: [FSItem]? = nil
    @objc dynamic public var items: [FSItem]?  {
        set {
            _items = newValue
        }
        get {
            if filterPredicate != nil {
                let result = _items?.filter({ $0.satisfyFilterPredicate })
                if !(result?.isEmpty ?? true){
                    return result
                } else {
                    if _items?.contains(where: { item in item.isFolder}) ?? false {
                        return _items
                    }
                    return result
                }
            } else {
                return _items
            }
        }
    }
    
    /// Return File item positioned in a particular IndexPath position
    ///
    /// - parameter indexPath: Array of indexPath of file item
    /// return: the file Item positioned at the IndexPath
    public func item(atIndexPath indexPath: IndexPath) -> FSItem? {
        var indexPath = indexPath
        var item = self
        while let index = indexPath.popFirst() {
            item = item._items![index]
        }
        return item
        
    }
    
    
    @objc func reindexChildren() {
        for (index,item) in (_items ?? []).enumerated()  {
            item.indexPath = self.indexPath.appending(index)
        }
    }

    
    fileprivate var satisfyFilterPredicate: Bool {
        if self.isFile {
            return filterPredicate!(self)
        } else {
            return _items!.reduce(false) { (result: Bool, item: FSItem) -> Bool in
                return result || item.satisfyFilterPredicate
            }
        }
    }
    
    /// Holds level of this file/folder
    public var level: Int = 0
    
    /// Get count of files in this folder
    @objc dynamic private var _totalFilesCount: Int = -1
    @objc dynamic public var totalFilesCount: Int {
        if _totalFilesCount == -1 {
            if !isFolder {
                _totalFilesCount = 1
            }  else {
                _totalFilesCount = items!.reduce(0, { x , y in
                    x + y.totalFilesCount
                })
            }
        }
        return _totalFilesCount
    }
    
    public var filesCount: Int {
        return items?.count ?? 0
    }
    
    class func keyPathsForValuesAffectingFilesCount() -> Set<AnyHashable>? {
        return Set<AnyHashable>(["items"])
    }
    
    
    /// Get count of subfolders in this folder
    private(set) var subfoldersCount = 0
    
    
    /// Returns RPC file indexes
    
    public var rpcFileIndexes: [Int: FSItem] {
        var rpcFileIndexes = [Int: FSItem]()
        if isFolder {
            for i in _items! {
                if i.isFile {
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
            for i in _items! {
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
            for i in _items! {
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
            for i in _items! {
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
            for i in _items! {
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
            for i in _items! {
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
    private var observerContext = 0
    
    /// Add new item to folder item
    public func add(withName name: String, isFolder: Bool) -> FSItem {
        let item = FSItem(name: name, isFolder: isFolder)
        
        item.level = self.level + 1
        item.parent = self
        item.indexPath = self.indexPath.appending(self.items!.count)
        items!.append(item)
        return item
    }

    
    public init(name: String, isFolder: Bool) {
        super.init()
        self.level = 0
        self.name = name
        self.isFolder = isFolder
        self.size = 0
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
        self.isWanted = true
        self.indexPath = IndexPath()
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
    
    public var sortPredicate: ((FSItem,FSItem)->Bool)? {
        didSet {
            self.sort()
            for file in self._items ?? [] {
                file.sortPredicate = self.sortPredicate
            }
        }
    }
    
    
    func sort() {
        if self.isFolder {
            if sortPredicate != nil {
                _items?.sort(by: sortPredicate!)
            } else {
                _items?.sort()
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
        else if lhs.isFolder && rhs.isFile  {
            return true
        }
        else if lhs.isFile && rhs.isFolder {
            return false
        }
        return lhs.fullName < rhs.fullName
    }
    
    public static func <= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName <= rhs.fullName
        }
        else if lhs.isFolder && rhs.isFile  {
            return true
        }
        else if lhs.isFile && rhs.isFolder {
            return false
        }
        return lhs.fullName <= rhs.fullName
    }
    
    public static func > (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName > rhs.fullName
        }
        else if lhs.isFolder && rhs.isFile  {
            return false
        }
        else if lhs.isFile && rhs.isFolder {
            return true
        }
        return lhs.fullName > rhs.fullName
    }
    
    public static func >= (lhs: FSItem, rhs: FSItem) -> Bool {
        if lhs.isFolder && rhs.isFolder {
            return lhs.fullName >= rhs.fullName
        }
        else if lhs.isFolder && rhs.isFile  {
            return false
        }
        else if lhs.isFile && rhs.isFolder {
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
    
    override open func isEqual(_ object: Any?) -> Bool {
        return (object as? FSItem)?.fullName == self.fullName
    }
    
    #if os(macOS)
    override open func isEqual(to object: Any?) -> Bool {
        return (object as? FSItem)?.fullName == self.fullName
    }

    override open func isNotEqual(to object: Any?) -> Bool {
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
        if let item = self.items?.first(where: {$0.name == itemName}) {
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
            newItem.priority = FilePriority(rawValue: (fileStatInfo[JSONKeys.priority] as? Int ?? 0) + 1) ?? .normal
        }
        self.size += newItem.size
    }
}
