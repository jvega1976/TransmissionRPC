//
//  MagnetURL.swift
//  TransmissionRPC
//
//  Created by Johnny Vega
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

private let TRSIZE_NOT_DEFINED = -1
private let kMagnetUrlSchemeName = "magnet"
private let kMagnetParamsSeparator = "&"
private let kMagnetContentSeparator = "?"
private let kMagnetParamPrefixTorrentSize = "xl="
private let kMagnetParamPrefixTorrentSizeString = "dl="
private let kMagnetParamPrefixTorrentName = "dn="
private let kMagnetParamPrefixTorrentTracker = "tr="
private let kMagnetParamPrefixTorrentHashUrn = "xt="
private let kMagnetParamPrefixTorrentHashParamSeparator = ":"
private let kMagnetComponentSeparator = "="

public struct MagnetURL {
    
    private var str = ""
    private var _hash = ""
    private var _trackers: [String]!
    private var size: Int = 0


    /// check if this url scheme is magnet
    public static func isMagnetURL(_ url: URL) -> Bool {
        return url.scheme == kMagnetUrlSchemeName
    }

    /// full url string

    public var urlString: String {
        return str
    }
    /// returns torrent name (if avalable) or hash string

    private var _name = ""
    public var name: String {
        var sn = NSLocalizedString("MagnetTorrentNameUnknown", comment: "")

        if _name != "" {
            sn = _name
        } else if _hash != "" {
            sn = String(format: NSLocalizedString("MagnetTorrentNameHash", comment: ""), _hash)
        }

        return sn
    }
    /// returns torrent size if avalable of @"unknown size"

    public var torrentSizeString: String {
        var sz = NSLocalizedString("MagnetTorrentSizeUnknown", comment: "")

        if Int(size) != TRSIZE_NOT_DEFINED {
            sz = formatByteCount(size)
        }

        return sz
    }
    /// returns tracker list if avalable or nil

    public var trackerList: [String] {
        return _trackers
    }

    public func getLongFromComponent(_ component: String) -> Int {
        let comps = component.components(separatedBy: "=")
        if comps.count == 2 {
            return Int(comps[1]) ?? 0
        }

        return 0
    }

    public func getStringFromComponent(_ component: String) -> String? {
        let comps = component.components(separatedBy: kMagnetComponentSeparator)

        if comps.count == 2 {
            return comps[1].removingPercentEncoding
        }

        return nil
    }

    public func getEncodedString(fromComponent component: String) -> String? {
        var s = getStringFromComponent(component)

        if s != nil {
            s = s?.replacingOccurrences(of: "+", with: " ")
            return s?.removingPercentEncoding
        }

        return nil
    }

    // parse magnet
    public mutating func parseMagnetString() {
        size = Int(TRSIZE_NOT_DEFINED)

        var comps = str.components(separatedBy: kMagnetContentSeparator)

        if comps.count > 0 {
            let s = comps.last

            if let components = s?.components(separatedBy: kMagnetParamsSeparator) {
                comps = components
            }

            _trackers = []

            if comps.count > 0 {
                for s in comps {
                    parseString(s)
                }
            } else {
                parseString(s ?? "")
            }
        }
    }

    public mutating func parseString(_ s: String) {
        if s.hasPrefix(kMagnetParamPrefixTorrentSize) {
            size = getLongFromComponent(s)
        } else if s.hasPrefix(kMagnetParamPrefixTorrentSizeString) {
            size = Int(getStringFromComponent(s) ?? "") ?? 0
        } else if s.hasPrefix(kMagnetParamPrefixTorrentHashUrn) {
            let stmp = getStringFromComponent(s)
            let ctmp = stmp?.components(separatedBy: kMagnetParamPrefixTorrentHashParamSeparator)
            _hash = ctmp?.last ?? ""
        } else if s.hasPrefix(kMagnetParamPrefixTorrentName) {
            _name = getEncodedString(fromComponent: s) ?? ""
        } else if s.hasPrefix(kMagnetParamPrefixTorrentTracker) {
            _trackers.append(getStringFromComponent(s) ?? "")
        }
    }

    public init(url: URL) {
        self._trackers = []
        self.str = url.description
        parseMagnetString()
    }
    
}
