//
//  RPCRequests.swift
//  TransmissionRPC
//
//  Created by Johnny A. Vega  on 10/19/19.
//  Copyright (c) 2019 Johnny Vega. All rights reserved.
//

import Foundation

/// Operation Object that administer the execution and data associated with a single RPC task request.
open class RPCRequest: Operation {
    
    private var session: RPCSession!
    private var task: URLSessionDataTask!
    
    
    /// A Boolean value indicating whether the operation executes its task asynchronously.
    override open var isAsynchronous: Bool {
        return false
    }
    
    
    /// A Boolean value indicating whether the operation is currently executing.
    /// - The value of this property is true if the operation is currently executing its main task or false if it is not.
    override open var isExecuting: Bool {
        return task.state == .running
    }
    
    
    /// A Boolean value indicating whether the operation has finished executing its task.
    /// - The value of this property is true if the operation has finished its main task or false if it is executing that task or has not yet started it.
    override open var isFinished: Bool {
        return task.state == .completed || task.state == .canceling
    }
    
    
    /// A Boolean value indicating whether the operation has been cancelled
    override open var isCancelled: Bool {
        return task.state == .canceling
    }
    
    
    /// Advises the operation object that it should stop executing its task.
    override open func cancel() {
        super.cancel()
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        willChangeValue(forKey: #keyPath(isCancelled))
        if task.state != .canceling {
            task.cancel()
        }
        didChangeValue(forKey: #keyPath(isExecuting))
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isCancelled))
    }
    
    
    /// Obtain the URLSessionDataTask priority based in an Operation Queue priority
    ///
    /// - parameter queuePriority: RPC request operation queue priotity
    /// - return: (Float) priority to use by the respective URLSessionDataTask
    private func dataTaskPriority(_ queuePriority:Operation.QueuePriority) -> Float {
        var priority: Float
        switch queuePriority {
            case .low,.veryLow:
                priority = URLSessionDataTask.lowPriority
            case .high,.veryHigh:
                priority = URLSessionDataTask.highPriority
            case .normal:
                priority = URLSessionDataTask.defaultPriority
            @unknown default:
                priority = URLSessionDataTask.lowPriority
        }
        return priority
    }
    
    
    /// Initializer
    ///
    /// - parameter method:
    ///     the RPC method name to request to the server
    /// - parameter arguments:
    ///     the arguments to provide to the requested method
    /// - parameter session:
    ///     RPCSession to process this request operation
    /// - parameter priority:
    ///     URLSession data task priority to use when this request is processed
    /// - parameter dataHandler:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter data:
    ///     The server response message encoded as a data object, if the request was succesful,
    ///     or nil if finished in error.
    ///     For message response format see https://github.com/transmission/transmission/blob/master/extras/rpc-spec.txt
    /// - parameter error:
    ///     An error object that indicates why the request failed,
    ///     or nil if the request was successful.
    ///
    public init(forMethod method: String, withArguments arguments:JSONObject?, usingSession session: RPCSession, andPriority priority: Operation.QueuePriority, dataCompletion dataHandler: @escaping(_ data: Data?,_ error: Error?) -> Void) {
        super.init()
        self.session = session
        self.name = method
        self.qualityOfService = .userInitiated
        self.queuePriority = priority
        
        guard let url = session.url else { return}
        
        var requestMessage =  [
            JSONKeys.method: method,
            ] as JSONObject
        if arguments != nil {
            requestMessage[JSONKeys.arguments] = arguments
        }
        
        var req: URLRequest = URLRequest(url: url)
        
        req.httpMethod = HTTP_REQUEST_METHOD
        
        // add authorization header
        if session.authString != "" {
            req.addValue(session.authString, forHTTPHeaderField: HTTP_AUTH_HEADER)
        }
        
        if session.xTransSessionId != "" {
            req.addValue(session.xTransSessionId, forHTTPHeaderField: HTTP_XTRANSID_HEADER)
        }
        
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: requestMessage, options: [.prettyPrinted])
            //print(req.httpBody!.string!)
        } catch {
            dataHandler(nil,error)
            return
        }
        req.timeoutInterval = TimeInterval(session.requestTimeout)
        
        self.task = session.sessionURL!.dataTask(with: req) { (data, response, error) in
            var error = error
            if error == nil {
                // check if if response not 200
                if (response is HTTPURLResponse) {
                    let httpResponse = response as? HTTPURLResponse
                    let statusCode = httpResponse?.statusCode ?? 0
                    let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    if statusCode != HTTP_RESPONSE_OK {
                        if statusCode == HTTP_RESPONSE_NEED_X_TRANS_ID {
                            self.session.xTransSessionId = httpResponse?.allHeaderFields[HTTP_XTRANSID_HEADER] as? String
                            let request = RPCRequest(forMethod: method, withArguments: arguments, usingSession: session, andPriority: .veryHigh, dataCompletion: dataHandler)
                            let sema = DispatchSemaphore(value: 0)
                            request.completionBlock = {
                                self.willChangeValue(forKey: #keyPath(isExecuting))
                                self.willChangeValue(forKey: #keyPath(isFinished))
                                sema.signal()
                            }
                            if request.isReady {
                                request.start()
                                sema.wait()
                            }
                            self.didChangeValue(forKey: #keyPath(isExecuting))
                            self.didChangeValue(forKey: #keyPath(isFinished))
                            return
                        }
                        error = NSError(domain: "TransmissionDomain", code: statusCode, userInfo: [NSLocalizedDescriptionKey: statusMessage])
                    }
                    else {
                        self.willChangeValue(forKey: #keyPath(isExecuting))
                        self.willChangeValue(forKey: #keyPath(isFinished))
                        dataHandler(data, nil)
                        self.didChangeValue(forKey: #keyPath(isExecuting))
                        self.didChangeValue(forKey: #keyPath(isFinished))
                        return
                    }
                }
            }
            if (error! as NSError).code != HTTP_RESPONSE_CANCELLED {
                self.willChangeValue(forKey: #keyPath(isExecuting))
                self.willChangeValue(forKey: #keyPath(isFinished))
                dataHandler(nil,error)
                self.didChangeValue(forKey: #keyPath(isExecuting))
                self.didChangeValue(forKey: #keyPath(isFinished))
            }
        }
        task.taskDescription = method
        task.priority = dataTaskPriority(priority)
    }
    
    
    /// Initializer
    ///
    /// - parameter method:
    ///     the RPC method name to request to the server
    /// - parameter arguments:
    ///     the arguments to provide to the requested method
    /// - parameter session:
    ///     RPCSession to process this request operation
    /// - parameter priority:
    ///     URLSession data task priority to use when this request is processed
    /// - parameter jsonHandler:
    ///     The completion handler to call when the server response is received.
    ///     This completion handler takes the following parameters:
    /// - parameter json:
    ///     The server response message as a JSON serialized onject,
    ///     if the request was succesful, or nil if finished in error.
    ///     For message response format see https://github.com/transmission/transmission/blob/master/extras/rpc-spec.txt
    /// - parameter error:
    ///     An error object that indicates why the request failed,
    ///     or nil if the request was successful.
    ///
    public init(forMethod method: String, withArguments arguments:JSONObject?, usingSession session: RPCSession, andPriority priority: Operation.QueuePriority, jsonCompletion jsonHandler: @escaping(_ json: JSONObject?,_ error: Error?) -> Void) {
        super.init()
        self.session = session
        self.name = method
        self.qualityOfService = .userInitiated
        self.queuePriority = priority
        
        guard let url = session.url else { return}
        
        var requestMessage =  [
            JSONKeys.method: method,
            ] as JSONObject
        if arguments != nil {
            requestMessage[JSONKeys.arguments] = arguments
        }
        
        var req: URLRequest = URLRequest(url: url)
        
        req.httpMethod = HTTP_REQUEST_METHOD
        
        // add authorization header
        if session.authString != "" {
            req.addValue(session.authString, forHTTPHeaderField: HTTP_AUTH_HEADER)
        }
        
        if session.xTransSessionId != "" {
            req.addValue(session.xTransSessionId, forHTTPHeaderField: HTTP_XTRANSID_HEADER)
        }
        
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: requestMessage, options: [.prettyPrinted])
        } catch {
            jsonHandler(nil,error)
            return
        }
        req.timeoutInterval = TimeInterval(session.requestTimeout)
        
        self.task = session.sessionURL!.dataTask(with: req) { (data, response, error) in
            var anError = error
            if anError == nil {
                // check if if response not 200
                if (response is HTTPURLResponse) {
                    let httpResponse = response as? HTTPURLResponse
                    let statusCode = httpResponse?.statusCode ?? 0
                    let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    if statusCode != HTTP_RESPONSE_OK {
                        if statusCode == HTTP_RESPONSE_NEED_X_TRANS_ID && statusCode != NSURLErrorCancelled {
                            self.session.xTransSessionId = httpResponse?.allHeaderFields[HTTP_XTRANSID_HEADER] as? String
                            let request = RPCRequest(forMethod: method, withArguments: arguments, usingSession: session, andPriority: .veryHigh, jsonCompletion: jsonHandler)
                            let sema = DispatchSemaphore(value: 0)
                            request.completionBlock = {
                                self.willChangeValue(forKey: #keyPath(isExecuting))
                                self.willChangeValue(forKey: #keyPath(isFinished))
                                sema.signal()
                            }
                            if request.isReady {
                                request.start()
                                sema.wait()
                            }
                            self.didChangeValue(forKey: #keyPath(isExecuting))
                            self.didChangeValue(forKey: #keyPath(isFinished))
                            return
                        }
                        anError = NSError(domain: "TransmissionDomain", code: statusCode, userInfo: [NSLocalizedDescriptionKey: statusMessage])
                    }
                    else {
                        self.willChangeValue(forKey: #keyPath(isExecuting))
                        self.willChangeValue(forKey: #keyPath(isFinished))
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? JSONObject
                            self.willChangeValue(forKey: #keyPath(isExecuting))
                            self.willChangeValue(forKey: #keyPath(isFinished))
                            jsonHandler(json,nil)
                            self.didChangeValue(forKey: #keyPath(isExecuting))
                            self.didChangeValue(forKey: #keyPath(isFinished))
                            return
                        } catch {
                            anError = error
                        }
                    }
                }
            }
            if (anError! as NSError).code != HTTP_RESPONSE_CANCELLED {
                self.willChangeValue(forKey: #keyPath(isExecuting))
                self.willChangeValue(forKey: #keyPath(isFinished))
                jsonHandler(nil,anError)
                self.didChangeValue(forKey: #keyPath(isExecuting))
                self.didChangeValue(forKey: #keyPath(isFinished))
            }
        }
        task.taskDescription = method
        task.priority = dataTaskPriority(priority)
    }
    
    
    /// Begins the execution of the operation.
    override open func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        if !isCancelled {
            task.resume()
        }
        didChangeValue(forKey: #keyPath(isExecuting))
    }
}
