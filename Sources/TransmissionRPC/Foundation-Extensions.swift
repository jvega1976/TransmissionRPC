//
//  FoundationExtensions.swift
//  Transmission Remote
//
//  Created by  on 7/28/19.
//

import Foundation

public extension NSObject {
    
    private static var selectedFlag = 0
    
    var dataObject: Any? {
        get {
            return objc_getAssociatedObject(self, &NSObject.selectedFlag)
        }
        set(dataObject) {
            objc_setAssociatedObject(self, &NSObject.selectedFlag, dataObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate let badChars = CharacterSet.alphanumerics.inverted

public extension String {
    
    var snakeCased: String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1-$2").lowercased()
    }
    
    var uppercasingFirst: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
    
    var camelCased: String {
        guard !self.isEmpty else {
            return ""
        }
        
        let parts = self.components(separatedBy: badChars)
        
        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})
        
        return ([first] + rest).joined(separator: "")
    }
}

/*!
 Returns formatted localized string for count of bytes
 @param bytes - count of bytes
 @return string representation (localized)
 */

public extension ByteCountFormatter {
    
    private static var formatByteCountFormatter: ByteCountFormatter {
        let myFormatByteCountFormatter = ByteCountFormatter()
        myFormatByteCountFormatter.allowsNonnumericFormatting = false
        myFormatByteCountFormatter.countStyle = .binary
        return myFormatByteCountFormatter
    }
    
    /// Converts a byte count value into a localized description that is formatted with the appropriate byte modifier (KB, MB, GB and so on).
    ///
    /// - parameter byteCount: Bytes count to convert
    ///
    class func formatByteCount(_ byteCount: Int = 0) -> String {
        
        if byteCount == 0 {
            return "0 KB"
        }
        
        return formatByteCountFormatter.string(fromByteCount: Int64(byteCount))
    }
    
    /// Converts a byte count per seconds value into a localized description that is formatted with the appropriate byte modifier (KB/s, MB/s, GB/s and so on)
    ///
    /// - parameter bytesPerSeconds: Bytes count to convert
    ///
    class func formatByteRate(_ bytesPerSeconds: Int = 0) -> String {
        return "\(formatByteCount(bytesPerSeconds))/s"
    }
    
}

/*!
 Returns formatted localized date string
 @param intevalSince1970 - time interval in seconds
 @return formatted localized date/time string - long mode
 */

public extension DateFormatter {
    
    private class func formatDateFormatter(withStyle style: DateFormatter.Style) -> DateFormatter {
        let locale = NSLocale.current as NSLocale
        let myFormatDateFormatter = DateFormatter()
        myFormatDateFormatter.locale = locale as Locale
        myFormatDateFormatter.timeStyle = .medium
        myFormatDateFormatter.dateStyle = style
        return myFormatDateFormatter
    }
    
    
    /// Return a string representation of a Datetime expressed as a TimeInterval object,
    /// using a medium format style
    /// - parameter seconds: TimeInterval (in seconds) to convert
    ///
    class func formatDateFrom1970(_ seconds: TimeInterval = 0.0) -> String {
        
        if seconds == 0 {
            return ""
        }
        
        let dt = Date(timeIntervalSince1970: seconds)
        return formatDateFormatter(withStyle:.medium).string(from: dt)
    }
    
    /// Return a string representation of a Date object using a medium format style
    /// - parameter date: Date to convert
    ///
    class func formatDate(_ date: Date?) -> String {
        guard let date = date else {return ""}
        return formatDateFormatter(withStyle:.medium).string(from: date)
    }
    
    
    /// Return a string representation of a Datetime expressed as a TimeInterval object,
    /// using a short format style
    /// - parameter seconds: Time interval in seconds
    ///
    class func formatDateFrom1970Short(_ seconds: TimeInterval = 0.0) -> String {
        
        if seconds == 0 {
            return ""
        }
        
        let dt = Date(timeIntervalSince1970: seconds)
        return formatDateFormatter(withStyle: .short).string(from: dt)
    }
    
    
    /// Return a string representation of a Time duration
    /// - parameter seconds: Time interval in seconds
    ///
    class func formatHoursMinutes(_ seconds: TimeInterval = 0.0) -> String {
        if seconds < 0 { return "..."}
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.month, .day, .hour, .minute, .second]
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.collapsesLargestUnit = false
        dateFormatter.maximumUnitCount = 3
        guard let secondsFormatted = dateFormatter.string(from: seconds) else { return ""}
        return secondsFormatted
    }
    
}


extension UInt8 {
    var bitBool: Array<Bool> {
        var arrayBool = Array(repeating: false, count: 8)
        for shift in 0...7 {
            arrayBool[shift] = (self >> shift) & 0x1 != 0 ? true : false
        }
        return arrayBool
    }
}

extension Data {
    var bitsAsBool: Array<Bool> {
        self.reduce(Array<Bool>()) { (boolArray, byte) -> Array<Bool> in
            return boolArray + byte.bitBool
        }
    }
}
