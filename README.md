# TransmissionRPC
Transmission RPC is a Xcode Development Framework written in Swift 5.0, that provide a highe level API to manage Transmission remote sessions throught the Transmission Remote Protocol 
(https://github.com/transmission/transmission/blob/master/extras/rpc-spec.txt)

## Installation

* Manual

Just clone the repository using command:

   git clone https://github.com/jvega1976/TransmissionRPC
   
* Using Swift Package

Just add the git repository to your project using the Xcode 11 option File->Swift Packages->Add Package Dependency


## How to use

There is two different ways of using TransmissionRPC.

You can use the hight level APIs to execute the RPC protocol methods, these hight level methods will return the reulting data using multiple class/structures provided by the Framework.

Example:

* First Create a Transmission session:

let session = RPCSession(withURL: "http://joe.doe:Password@host.domain.com:9091/transmission/rpc", andTimeout: 10)

Note:  If the Transmission Remote sever is configured with user authentication, then the url must contains the user and password credentials.

* Then use the new session to execute the RPC methods:

To get the detail info for all Torrents you can pass nil in the forTorrents parameter


    session.getInfo(forTorrents: nil, withPriority: .normal, andCompletionHandler: {

      torrents, removedTorrents, error in
      if error != nil {
        print(error.localizedDescription)
      } else {
        for torrent in torrents {
            print("Torrent Name: \(torrent.name)")
        }
      }
    })

To start the processing of Torrents with id 58, 189 and 27 use:


    session.start(torrents: [58, 189, 27], withPriority: .high, completionHandler: { error in
       if error != nil {
           print("Start torrents request finished with Error:  \(error.localizedDescription)")
       }
    })


Or you can use one of the two low level API that can return the request output using a Serialized object or an Data object representing the JSON Transmission server response.

    let arguments = [ "arguments" : [ 
                                      "fields": [ "id", "name", "totalSize" ],
                                      "ids": [ 7, 10 ]
                                     ]
                     ]
                     
    let request = Request(forMethod: "get-torrent", withArguments:  arguments, usingSession: session, andPriority: .normal, jsonCompletion: { data, error in
        if error != nil {
            print(error.localizedDescription)
            return
        } 
        guard let arguments = json?["arguments"] as? [String: Any],
            let torrents = arguments["torrents"] as? Array<[String:Any]> else { return }
            for torrent in torrents {
                print("Torrent Name: \(torrent["name"])")    
            }
    })

    request.completionBlock = { 
        if !request.isCancelled {
                print("RPC request have finished") 
        }
     }

    session.addTorrentRequest(request)

