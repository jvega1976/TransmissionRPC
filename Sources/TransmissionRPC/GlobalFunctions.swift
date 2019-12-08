
//
//  GlobalFunctions.swift
//  TransmissionRPC
//
//  Created by Johnny Vega 
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

/*!
    Returns formatted localized string for count of bytes
    @param bytes - count of bytes
    @return string representation (localized)
 */

fileprivate var formatByteCountFormatter: ByteCountFormatter {
    let myFormatByteCountFormatter = ByteCountFormatter()
    myFormatByteCountFormatter.allowsNonnumericFormatting = false
    myFormatByteCountFormatter.countStyle = .binary
    return myFormatByteCountFormatter
}

/// Converts a byte count value into a localized description that is formatted with the appropriate byte modifier (KB, MB, GB and so on).
///
/// - parameter byteCount: Bytes count to convert
///
public func formatByteCount(_ byteCount: Int = 0) -> String {

    if byteCount == 0 {
        return "0 KB"
    }
    
    return formatByteCountFormatter.string(fromByteCount: Int64(byteCount))
}

/// Converts a byte count per seconds value into a localized description that is formatted with the appropriate byte modifier (KB/s, MB/s, GB/s and so on)
///
/// - parameter bytesPerSeconds: Bytes count to convert
///
public func formatByteRate(_ bytesPerSeconds: Int = 0) -> String {
    return "\(formatByteCount(bytesPerSeconds))/s"
}

/*!
     Returns formatted localized date string
     @param intevalSince1970 - time interval in seconds
     @return formatted localized date/time string - long mode
 */
fileprivate func formatDateFormatter(withStyle style:DateFormatter.Style) -> DateFormatter {
    let locale = NSLocale.current as NSLocale
    let myFormatDateFormatter = DateFormatter()
    myFormatDateFormatter.locale = locale as Locale
    myFormatDateFormatter.timeStyle = .short
    myFormatDateFormatter.dateStyle = style
    return myFormatDateFormatter
}


/// Return a string representation of a Datetime expressed as a TimeInterval object,
/// using a medium format style
/// - parameter seconds: TimeInterval (in seconds) to convert
///
public func formatDateFrom1970(_ seconds: TimeInterval = 0.0) -> String {

    if seconds == 0 {
        return ""
    }

    let dt = Date(timeIntervalSince1970: seconds)
    return formatDateFormatter(withStyle:.medium).string(from: dt)
}

/// Return a string representation of a Date object using a medium format style
/// - parameter date: Date to convert
///
public func formatDate(_ date: Date?) -> String? {
    guard let date = date else {return nil}
    return formatDateFormatter(withStyle:.medium).string(from: date)
}


/// Return a string representation of a Datetime expressed as a TimeInterval object,
/// using a short format style
/// - parameter seconds: Time interval in seconds
///
public func formatDateFrom1970Short(_ seconds: TimeInterval = 0.0) -> String? {

    if seconds == 0 {
        return ""
    }

    let dt = Date(timeIntervalSince1970: seconds)
    return formatDateFormatter(withStyle: .short).string(from: dt)
}


/// Return a string representation of a Time duration
/// - parameter seconds: Time interval in seconds
///
public func formatHoursMinutes(_ seconds: TimeInterval = 0.0) -> String {
    if seconds < 0 { return "Estimating"}
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.allowedUnits = [.month, .day, .hour, .minute, .second]
    dateFormatter.unitsStyle = .abbreviated
    dateFormatter.collapsesLargestUnit = false
    dateFormatter.maximumUnitCount = 3
    guard let secondsFormatted = dateFormatter.string(from: seconds) else { return ""}
    return secondsFormatted
}
