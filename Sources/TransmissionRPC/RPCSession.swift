//  RPCSession.swift
//  TransmissionRPC
//
//  Main Transmission RPC API
//
//  Created by Johnny Vega  on 10.02.19
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//


import Foundation
import os
import Combine

let HTTP_RESPONSE_OK = 200
let HTTP_RESPONSE_UNAUTHORIZED = 401
let HTTP_RESPONSE_NEED_X_TRANS_ID = 409
let HTTP_RESPONSE_CANCELLED = -999
let HTTP_REQUEST_METHOD = "POST"
let HTTP_AUTH_HEADER = "Authorization"
let HTTP_XTRANSID_HEADER = "X-Transmission-Session-Id"

enum RPCSessionError: Error  {
    case invalidxTransSessionId
}


// MARK: - RPCSession.
///The RPCSession provide the main APIs to send requests to the Transmission RPC server.
open class RPCSession: NSObject, ObservableObject {
    
    ///Common Standard Share Session (singleton)
    ///return a common `RPCSession` available for use through multiple interface components
    public static var shared: RPCSession? = nil
    
    /// Allow to configure the URL Session to use for communication with the RPC server
    internal var sessionConfig : URLSessionConfiguration!
    
    /// Operation queue to control tasks execution
    private var sessionURLQueue : OperationQueue!
    
    /// Operation queue to control RPC requests execution
    internal var torrentQueue : OperationQueue!
    
    /// Operation queue to control RPC requests execution
    internal var sessionConfigQueue : OperationQueue!
    
    /// URL Session to use for communication with the RPC server
    internal var sessionURL: URLSession!
    
    /// Authentication string for RPC server session authentication
    public var authString = "" // holds auth info or nil
    
    /// RPC Server url
    public var url: URL!
    
    /// Request Timeout in seconds
    public var requestTimeout: TimeInterval = 10

    /// the Transmission Session Identifier
    public var xTransSessionId: String! = ""
    
    /// Simple Initializer
    ///
    public override init() {
        super.init()
        self.url = URL(string: "")
        self.requestTimeout = 0
        self.authString = ""
        sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        if #available(iOS 13.0, *) {
            sessionConfig.allowsExpensiveNetworkAccess = true
        } else {
            // Fallback on earlier versions
        }
        #if os(iOS)
        sessionConfig.sessionSendsLaunchEvents = true
        #endif
        sessionConfig.waitsForConnectivity = true
        sessionConfig.shouldUseExtendedBackgroundIdleMode = true
        sessionURLQueue = OperationQueue()
        sessionURLQueue.maxConcurrentOperationCount = 2
        sessionURLQueue.qualityOfService = .userInteractive
        self.sessionURL = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: sessionURLQueue)
        torrentQueue = OperationQueue()
        torrentQueue.maxConcurrentOperationCount = 1
        torrentQueue.qualityOfService = .userInteractive
        sessionConfigQueue = OperationQueue()
        sessionConfigQueue.maxConcurrentOperationCount = 1
        torrentQueue.qualityOfService = .userInteractive
        
    }
    
    
    /// Object instance initializer
    ///
    /// - parameter url: Transmission RPC server URL
    /// - parameter timeout: session request timeout (in seconds)
    ///
    public init?(withURL url: URL, andTimeout timeout: TimeInterval) throws {
        super.init()
        self.url = url
        self.requestTimeout = timeout
        sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        if #available(iOS 13.0, *) {
            sessionConfig.allowsExpensiveNetworkAccess = true
        } else {
            // Fallback on earlier versions
        }
        #if os(iOS)
        sessionConfig.sessionSendsLaunchEvents = true
        #endif
        sessionConfig.waitsForConnectivity = false
        sessionConfig.shouldUseExtendedBackgroundIdleMode = true
        sessionConfig.timeoutIntervalForRequest = self.requestTimeout
        sessionConfig.httpMaximumConnectionsPerHost = 2
        sessionURLQueue = OperationQueue()
        sessionURLQueue.maxConcurrentOperationCount = 2
        sessionURLQueue.qualityOfService = .userInitiated
        sessionURL = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: sessionURLQueue)
        torrentQueue = OperationQueue()
        torrentQueue.maxConcurrentOperationCount = 1
        torrentQueue.qualityOfService = .userInitiated
        sessionConfigQueue = OperationQueue()
        sessionConfigQueue.maxConcurrentOperationCount = 1
        sessionConfigQueue.qualityOfService = .userInitiated
        // add auth header if there is username
        authString = ""
        if (url.user != nil) {
            let authStringToEncode64 = "\(url.user!):\(url.password ?? "")"
            let data = authStringToEncode64.data(using: .utf8)
            authString = "Basic \(data?.base64EncodedString(options: []) ?? "")"
        }
        guard let xTransSessionId = try getXTransSessionId() else { throw RPCSessionError.invalidxTransSessionId }
        self.xTransSessionId = xTransSessionId
    }
    
    deinit {
        sessionConfigQueue.cancelAllOperations()
        torrentQueue.cancelAllOperations()
        sessionURL.invalidateAndCancel()
    }
    
    
    private func getXTransSessionId() throws -> String? {
        guard let url = self.url else { return nil}
        let requestMessage = [JSONKeys.method : JSONKeys.port_test]
        var req: URLRequest = URLRequest(url: url)
        let sema = DispatchSemaphore(value: 0)
        
        req.httpMethod = HTTP_REQUEST_METHOD
        
        // add authorization header
        if authString != "" {
            req.addValue(authString, forHTTPHeaderField: HTTP_AUTH_HEADER)
        }
        
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: requestMessage, options: [.prettyPrinted])
        } catch {
            os_log("%@",error.localizedDescription)
            throw error
        }
        req.timeoutInterval = TimeInterval(requestTimeout)
        var xTransSessionId: String?
        var anError: Error?
        let task = self.sessionURL.dataTask(with: req) { (data, response, error) in
            if error != nil {
                os_log("%@",error!.localizedDescription)
                anError = error
            } else if (response is HTTPURLResponse) {
                let httpResponse = response as? HTTPURLResponse
                let statusCode = httpResponse?.statusCode ?? 0
                if statusCode != HTTP_RESPONSE_OK {
                    if statusCode == HTTP_RESPONSE_NEED_X_TRANS_ID {
                        xTransSessionId = httpResponse?.allHeaderFields[HTTP_XTRANSID_HEADER] as? String
                    }
                } else {
                    anError = NSError(domain: "TransmissionRemote", code: statusCode, userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)])
                }
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
        if anError != nil {
            throw anError!
        }
        return xTransSessionId
    }
    
    
    /// Cancel actual and pending task requests in queues
    ///
    public func stopRequests() {
        if self.torrentQueue.operationCount > 0 {
            self.torrentQueue.cancelAllOperations()
        }
        if self.sessionConfigQueue.operationCount > 0 {
            self.sessionConfigQueue.cancelAllOperations()
        }
    }
    
    
    /// Add a RPC request task into the Torrent Operations queue
    ///
    /// - parameter request: RPC request to process
    ///
    public func addTorrentRequest(_ request: Operation) {
        self.torrentQueue.addOperation(request)
    }
    
    
    /// Add a RPC request task into the Session Operations queue
    ///
    /// - parameter request: RPC request to process
    ///
    public func addSessionConfigRequest(_ request: Operation) {
        self.sessionConfigQueue.addOperation(request)
    }
    
    
    /// Restart an RPC session, returning true if session was restarted sucessfully, otherwise false
    ///
    public func restart() throws {
        self.xTransSessionId = try getXTransSessionId()
    }
}
