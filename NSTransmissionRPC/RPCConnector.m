//
//  RPCConnector.m
//  TransmissionRPCClient
//

#import <Foundation/Foundation.h>
#import "RPCConnector.h"

#define HTTP_RESPONSE_OK                    200
#define HTTP_RESPONSE_UNAUTHORIZED          401
#define HTTP_RESPONSE_NEED_X_TRANS_ID       409
#define HTTP_REQUEST_METHOD                 @"POST"
#define HTTP_AUTH_HEADER                    @"Authorization"
#define HTTP_XTRANSID_HEADER                @"X-Transmission-Session-Id"

@interface RPCConnector ()

@property (nonatomic)     NSString        *xTransSessionId;

@end

@implementation RPCConnector

{
                    
    NSURLSession    *_session;                      // holds session
    NSString        *_authString;                   // holds auth info or nil
    
    NSURLSessionDataTask *_task;                    // holds current data task
}

// get all torrents and save them in array
- (void)getAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
        TR_METHOD : TR_METHODNAME_TORRENTGET,
        TR_METHOD_ARGS : @{
                TR_ARG_FIELDS : @[
                        TR_ARG_FIELDS_ID,
                        TR_ARG_FIELDS_NAME,
                        TR_ARG_FIELDS_STATUS,
                        TR_ARG_FIELDS_ERRORNUM,
                        TR_ARG_FIELDS_ERRORSTRING,
                        TR_ARG_FIELDS_TOTALSIZE,
                        TR_ARG_FIELDS_PERCENTDONE,
                        TR_ARG_FIELDS_RATEDOWNLOAD,
                        TR_ARG_FIELDS_RATEUPLOAD,
                        TR_ARG_FIELDS_PEERSCONNECTED,
                        TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                        TR_ARG_FIELDS_PEERSSENDINGTOUS,
                        TR_ARG_FIELDS_UPLOADEDEVER,
                        TR_ARG_FIELDS_UPLOADRATIO,
                        TR_ARG_FIELDS_QUEUEPOSITION,
                        TR_ARG_FIELDS_RECHECKPROGRESS,
                        TR_ARG_FIELDS_DOWNLOADEDEVER,
                        TR_ARG_FIELDS_ETA,
                        TR_ARG_FIELDS_SEEDRATIOMODE,
                        TR_ARG_FIELDS_SEEDRATIOLIMIT,
                        TR_ARG_FIELDS_SEEDIDLEMODE,
                        TR_ARG_FIELDS_SEEDIDLELIMIT,
                        TR_ARG_FIELDS_UPLOADLIMITED,
                        TR_ARG_FIELDS_UPLOADLIMIT,
                        TR_ARG_FIELDS_DOWNLOADLIMITED,
                        TR_ARG_FIELDS_DOWNLOADLIMIT,
                        TR_ARG_FIELDS_HAVEVALID,
                        TR_ARG_FIELDS_DOWNLOADDIR,
                        TR_ARG_FIELDS_ISFINISHED,
                        TR_ARG_FIELDS_PIECECOUNT,
                        TR_ARG_FIELDS_PIECESIZE,
                        TR_ARG_FIELDS_PEERLIMIT,
                        TR_ARG_FIELDS_BANDWIDTHPRIORITY,
                        TR_ARG_FIELDS_DONEDATE,
                        TR_ARG_FIELDS_ADDDATE,
                        TR_ARG_FIELDS_DATECREATED
                    ]
        }
    };
   
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
    {
        // save torrents and call delegate
        NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
        
        [TRInfos.shared setInfosFromArrayOfJSON:torrentsJsonDesc];

        if( delegate && [delegate respondsToSelector:@selector(gotAllTorrents:)])
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate gotAllTorrents:TRInfos.shared];
            });
    }];
}

- (void)getRecentlyActiveTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[
                                                  TR_ARG_FIELDS_ID,
                                                  TR_ARG_FIELDS_NAME,
                                                  TR_ARG_FIELDS_STATUS,
                                                  TR_ARG_FIELDS_ERRORNUM,
                                                  TR_ARG_FIELDS_ERRORSTRING,
                                                  TR_ARG_FIELDS_TOTALSIZE,
                                                  TR_ARG_FIELDS_PERCENTDONE,
                                                  TR_ARG_FIELDS_RATEDOWNLOAD,
                                                  TR_ARG_FIELDS_RATEUPLOAD,
                                                  TR_ARG_FIELDS_PEERSCONNECTED,
                                                  TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                                                  TR_ARG_FIELDS_PEERSSENDINGTOUS,
                                                  TR_ARG_FIELDS_UPLOADEDEVER,
                                                  TR_ARG_FIELDS_UPLOADRATIO,
                                                  TR_ARG_FIELDS_QUEUEPOSITION,
                                                  TR_ARG_FIELDS_RECHECKPROGRESS,
                                                  TR_ARG_FIELDS_DOWNLOADEDEVER,
                                                  TR_ARG_FIELDS_ETA,
                                                  TR_ARG_FIELDS_SEEDRATIOMODE,
                                                  TR_ARG_FIELDS_SEEDRATIOLIMIT,
                                                  TR_ARG_FIELDS_SEEDIDLEMODE,
                                                  TR_ARG_FIELDS_SEEDIDLELIMIT,
                                                  TR_ARG_FIELDS_UPLOADLIMITED,
                                                  TR_ARG_FIELDS_UPLOADLIMIT,
                                                  TR_ARG_FIELDS_DOWNLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADLIMIT,
                                                  TR_ARG_FIELDS_HAVEVALID,
                                                  TR_ARG_FIELDS_DOWNLOADDIR,
                                                  TR_ARG_FIELDS_ISFINISHED,
                                                  TR_ARG_FIELDS_PIECECOUNT,
                                                  TR_ARG_FIELDS_PIECESIZE,
                                                  TR_ARG_FIELDS_PEERLIMIT,
                                                  TR_ARG_FIELDS_BANDWIDTHPRIORITY,
                                                  TR_ARG_FIELDS_DONEDATE,
                                                  TR_ARG_FIELDS_ADDDATE,
                                                  TR_ARG_FIELDS_DATECREATED
                                                  ],
                                          TR_ARG_IDS : TR_RECENTLY_ACTIVE
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         TRInfos *trInfos = [TRInfos initWithArrayOfJSON:torrentsJsonDesc];
         
         if( delegate && [delegate respondsToSelector:@selector(gotRecentlyActiveTorrents:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotRecentlyActiveTorrents:trInfos];
             });
     }];
}


- (TRInfos*)returnAllTorrents
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[
                                                  TR_ARG_FIELDS_ID,
                                                  TR_ARG_FIELDS_NAME,
                                                  TR_ARG_FIELDS_STATUS,
                                                  TR_ARG_FIELDS_ERRORNUM,
                                                  TR_ARG_FIELDS_ERRORSTRING,
                                                  TR_ARG_FIELDS_TOTALSIZE,
                                                  TR_ARG_FIELDS_PERCENTDONE,
                                                  TR_ARG_FIELDS_RATEDOWNLOAD,
                                                  TR_ARG_FIELDS_RATEUPLOAD,
                                                  TR_ARG_FIELDS_PEERSCONNECTED,
                                                  TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                                                  TR_ARG_FIELDS_PEERSSENDINGTOUS,
                                                  TR_ARG_FIELDS_UPLOADEDEVER,
                                                  TR_ARG_FIELDS_UPLOADRATIO,
                                                  TR_ARG_FIELDS_QUEUEPOSITION,
                                                  TR_ARG_FIELDS_RECHECKPROGRESS,
                                                  TR_ARG_FIELDS_DOWNLOADEDEVER,
                                                  TR_ARG_FIELDS_ETA,
                                                  TR_ARG_FIELDS_SEEDRATIOMODE,
                                                  TR_ARG_FIELDS_SEEDRATIOLIMIT,
                                                  TR_ARG_FIELDS_SEEDIDLEMODE,
                                                  TR_ARG_FIELDS_SEEDIDLELIMIT,
                                                  TR_ARG_FIELDS_UPLOADLIMITED,
                                                  TR_ARG_FIELDS_UPLOADLIMIT,
                                                  TR_ARG_FIELDS_DOWNLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADLIMIT,
                                                  TR_ARG_FIELDS_HAVEVALID,
                                                  TR_ARG_FIELDS_DOWNLOADDIR,
                                                  TR_ARG_FIELDS_ISFINISHED,
                                                  TR_ARG_FIELDS_PIECECOUNT,
                                                  TR_ARG_FIELDS_PIECESIZE,
                                                  TR_ARG_FIELDS_PEERLIMIT,
                                                  TR_ARG_FIELDS_BANDWIDTHPRIORITY,
                                                  TR_ARG_FIELDS_DONEDATE,
                                                  TR_ARG_FIELDS_ADDDATE,
                                                  TR_ARG_FIELDS_DATECREATED
                                                  ]
                                          }
                                  };
    TRInfos __block *trInfos;
    dispatch_semaphore_t  __block sema = dispatch_semaphore_create(0);
    [self makeRequest:requestVals forDelegate:nil withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
        NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
        trInfos = [TRInfos initWithArrayOfJSON:torrentsJsonDesc];
         dispatch_semaphore_signal(sema);
     }];
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    return trInfos;
}


// request detailed info for torrent with id - torrentId
- (void)getDetailedInfoForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[
                                                  TR_ARG_FIELDS_ID,
                                                  TR_ARG_FIELDS_NAME,
                                                  TR_ARG_FIELDS_STATUS,
                                                  TR_ARG_FIELDS_TOTALSIZE,
                                                  TR_ARG_FIELDS_PERCENTDONE,
                                                  TR_ARG_FIELDS_RATEDOWNLOAD,
                                                  TR_ARG_FIELDS_RATEUPLOAD,
                                                  TR_ARG_FIELDS_PEERSCONNECTED,
                                                  TR_ARG_FIELDS_PEERSGETTINGFROMUS,
                                                  TR_ARG_FIELDS_PEERSSENDINGTOUS,
                                                  TR_ARG_FIELDS_UPLOADEDEVER,
                                                  TR_ARG_FIELDS_UPLOADRATIO,
                                                  TR_ARG_FIELDS_ACTIVITYDATE,
                                                  TR_ARG_FIELDS_COMMENT,
                                                  TR_ARG_FIELDS_CREATOR,
                                                  TR_ARG_FIELDS_DATECREATED,
                                                  TR_ARG_FIELDS_DONEDATE,
                                                  TR_ARG_FIELDS_ERRORNUM,
                                                  TR_ARG_FIELDS_ERRORSTRING,
                                                  TR_ARG_FIELDS_HASHSTRING,
                                                  TR_ARG_FIELDS_PIECECOUNT,
                                                  TR_ARG_FIELDS_PIECESIZE,
                                                  TR_ARG_FIELDS_SECONDSDOWNLOADING,
                                                  TR_ARG_FIELDS_SECONDSSEEDING,
                                                  TR_ARG_FIELDS_STARTDATE,
                                                  TR_ARG_FIELDS_HAVEVALID,
                                                  TR_ARG_FIELDS_HAVEUNCHECKED,
                                                  TR_ARG_FIELDS_RECHECKPROGRESS,
                                                  TR_ARG_FIELDS_DOWNLOADEDEVER,
                                                  TR_ARG_FIELDS_ETA,
                                                  TR_ARG_FIELDS_BANDWIDTHPRIORITY,
                                                  TR_ARG_FIELDS_QUEUEPOSITION,
                                                  TR_ARG_FIELDS_HONORSSESSIONLIMITS,
                                                  TR_ARG_FIELDS_SEEDIDLELIMIT,
                                                  TR_ARG_FIELDS_SEEDIDLEMODE,
                                                  TR_ARG_FIELDS_SEEDRATIOLIMIT,
                                                  TR_ARG_FIELDS_SEEDRATIOMODE,
                                                  TR_ARG_FIELDS_UPLOADLIMIT,
                                                  TR_ARG_FIELDS_UPLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADLIMIT,
                                                  TR_ARG_FIELDS_DOWNLOADLIMITED,
                                                  TR_ARG_FIELDS_DOWNLOADDIR
                                                  ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         TRInfo *trInfo = [TRInfo infoFromJSON:[torrentsJsonDesc firstObject]];
         
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentDetailedInfo:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentDetailedInfo:trInfo];
             });
     }];
}

- (void)getMagnetURLforTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{ TR_ARG_FIELDS : @[ TR_ARG_FIELDS_MAGNETLINK ],  TR_ARG_IDS : @[@(torrentId)] }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSString *magnetUrlString = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_MAGNETLINK];
         
         if( delegate && [delegate respondsToSelector:@selector(gotMagnetURL:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotMagnetURL:magnetUrlString forTorrentWithId:torrentId];
             });
     }];
}


- (void)getAllPeersForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_PEERS, TR_ARG_FIELDS_PEERSFROM ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSMutableArray *peerInfos = [NSMutableArray array];
         
         for( NSDictionary* peerJsonDict in [torrentsJsonDesc firstObject][TR_ARG_FIELDS_PEERS] )
             [peerInfos addObject:[TRPeerInfo peerInfoWithJSONData:peerJsonDict]];
         
         TRPeerStat *peerStat = [TRPeerStat peerStatWithJSONData:[torrentsJsonDesc firstObject][TR_ARG_FIELDS_PEERSFROM]];
         
         if( delegate && [delegate respondsToSelector:@selector(gotAllPeers:withPeerStat:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllPeers:peerInfos withPeerStat:peerStat forTorrentWithId:torrentId];
             });
     }];
}

- (void)getAllFilesForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_FILES, TR_ARG_FIELDS_FILESTATS],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSArray* files = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILES];
         NSArray* fileStats = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_FILESTATS];
         
         // ** Benchmarking **
         //CFTimeInterval tmStart = CACurrentMediaTime();
         // --------------------------------------------
         FSDirectory *fsDir = [FSDirectory directory];
         
         for( int i = 0; i < files.count; i++ )
             [fsDir addItemWithJSONFileInfo:files[i] JSONFileStatInfo:fileStats[i] rpcIndex:i];
         
         // --------------------------------------------
         //CFTimeInterval tmEnd = CACurrentMediaTime();
         //NSLog( @"%s, run time: %g s", __PRETTY_FUNCTION__,  tmEnd - tmStart );
         
         
         [fsDir sort];
         
         if( delegate && [delegate respondsToSelector:@selector(gotAllFiles:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllFiles:fsDir forTorrentWithId:torrentId];
             });
     }];    
}

- (void)getAllFileStatsForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{ TR_ARG_FIELDS : @[ TR_ARG_FIELDS_FILESTATS], TR_ARG_IDS : @[@(torrentId)] }
                                 };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrents = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         NSArray* fileStats = [torrents firstObject][TR_ARG_FIELDS_FILESTATS];
         
         NSMutableArray *res = [NSMutableArray array];
         
         for( NSDictionary *fileStatJSON in fileStats )
         {
             TRFileStat *fileStat = [TRFileStat fileStatFromJSON:fileStatJSON];
             [res addObject:fileStat];
         }
         
         if( delegate && [delegate respondsToSelector:@selector(gotAllFileStats:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllFileStats:res forTorrentWithId:torrentId];
             });
     }];
}

- (void)getAllTrackersForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_TRACKERSTATS ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSArray* trackerStats = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_TRACKERSTATS];
         
         NSMutableArray *res = [NSMutableArray array];
         
         for( NSDictionary *dict in trackerStats )
             [res addObject:[TrackerStat initFromJSON:dict]];
         
         if( delegate && [delegate respondsToSelector:@selector(gotAllTrackers:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllTrackers:res forTorrentWithId:torrentId];
             });
     }];
}

- (void)getPiecesBitMapForTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{  // __strong typeof(delegate) delegate = _delegate;
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTGET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS : @[ TR_ARG_FIELDS_PIECES ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTGET andHandler:^(NSDictionary *json)
     {
         // save torrents and call delegate
         NSArray *torrentsJsonDesc = json[TR_RETURNED_ARGS][TR_RETURNED_ARG_TORRENTS];
         
         NSString* base64data = [torrentsJsonDesc firstObject][TR_ARG_FIELDS_PIECES];
 
         NSData *data = [[NSData alloc] initWithBase64EncodedString:base64data options:NSDataBase64DecodingIgnoreUnknownCharacters];
         
         if( delegate && [delegate respondsToSelector:@selector(gotPiecesBitmap:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotPiecesBitmap:data forTorrentWithId:torrentId];
             });
     }];
}


- (void)addTrackers:(NSArray*)trackerURL forTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS_TRACKERADD : trackerURL,
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTrackersAdded:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTrackersAdded:trackerURL forTorrentWithId:torrentId];
             });
     }];
}


- (void)removeTracker:(int)trackerId forTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS_TRACKERREMOVE : @[ @(trackerId) ],
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTrackerRemoved:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTrackerRemoved:trackerId forTorrentWithId:torrentId];
             });
     }];
}

- (void)setSettings:(TRInfo *)info forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{
                                          TR_ARG_FIELDS_QUEUEPOSITION : @(info.queuePosition),
                                          TR_ARG_FIELDS_BANDWIDTHPRIORITY : @(info.bandwidthPriority),
                                          TR_ARG_FIELDS_UPLOADLIMITED : @(info.uploadLimitEnabled),
                                          TR_ARG_FIELDS_UPLOADLIMIT : @(info.uploadLimit),
                                          TR_ARG_FIELDS_DOWNLOADLIMITED : @(info.downloadLimitEnabled),
                                          TR_ARG_FIELDS_DOWNLOADLIMIT : @(info.downloadLimit),
                                          TR_ARG_FIELDS_SEEDIDLEMODE : @(info.seedIdleMode),
                                          TR_ARG_FIELDS_SEEDIDLELIMIT : @(info.seedIdleLimit),
                                          TR_ARG_FIELDS_SEEDRATIOMODE : @(info.seedRatioMode),
                                          TR_ARG_FIELDS_SEEDRATIOLIMIT : @(info.seedRatioLimit),
                                          TR_ARG_FIELDS_PEERLIMIT : @(info.peerLimit),
                                          TR_ARG_IDS : @[@(torrentId)]
                                          }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotSetSettingsForTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotSetSettingsForTorrentWithId:torrentId];
             });
     }];
}

- (void)stopTorrents:(NSArray*)torrentsId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSTOP,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentsId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSTOP andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotAllTorrentsStopped)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllTorrentsStopped];
             });
     }];
}

- (void)stopAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TORRENTSTOP };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSTOP andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotAllTorrentsStopped)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAllTorrentsStopped];
             });
     }];    
}

- (void)resumeTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTRESUME,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTRESUME andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentResumedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAlltorrentsResumed];
             });
     }];
}

- (void)resumeNowTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTRESUMENOW,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTRESUMENOW andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentResumedWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAlltorrentsResumed];
             });
     }];
}


- (void)resumeAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TORRENTRESUME };
      
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTRESUME andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotAlltorrentsResumed)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotAlltorrentsResumed];
             });
     }];
}

- (void)verifyTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTVERIFY,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTVERIFY andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsVerified)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsVerified];
             });
     }];
}

- (void)reannounceTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTREANNOUNCE,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTREANNOUNCE andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsReannounced)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsReannounced];
             });
     }];
}

- (void)deleteTorrentWithId:(NSArray*)torrentId deleteWithData:(BOOL)deleteWithData forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTREMOVE,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId, TR_ARG_DELETELOCALDATA:@(deleteWithData) }};
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTREMOVE andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsDeleted)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsDeleted];
             });
     }];
}


- (void)moveTorrentQueue:(NSArray*)torrentId toPosition:(NSArray*)position forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    
    for (int i=0;i<torrentId.count;i++) {
        NSNumber *trId = [torrentId objectAtIndex:i];
        NSNumber *pos = [position objectAtIndex:i];
        NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : trId, TR_ARG_FIELDS_QUEUEPOSITION:pos}};
         NSLog(@"%@",requestVals);
        [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTREMOVE andHandler:^(NSDictionary *json)
         {
             NSLog(@"%@",json);
         }];
    }
    if( delegate && [delegate respondsToSelector:@selector(gotTorrentsMoved)])
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate gotTorrentsMoved];
        });
}

- (void)moveTorrentUp:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTUP,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTUP andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsMoved)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsMoved];
             });
     }];
}


- (void)moveTorrentDown:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTDOWN,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTDOWN andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsMoved)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsMoved];
             });
     }];
}


- (void)moveTorrentTop:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTTOP,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTTOP andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsMoved)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsMoved];
             });
     }];
}


- (void)moveTorrentBottom:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTBOTTOM,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : torrentId }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTBOTTOM andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentsMoved)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentsMoved];
             });
     }];
}


- (void)addTorrentWithFile:(TorrentFile*)torrentFile priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSString *base64content = [torrentFile.torrentData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_METAINFO : base64content,
                                                      TR_ARG_FIELDS_FILES_UNWANTED : torrentFile.fileList.rootItem.rpcFileIndexesUnwanted,
                                                      TR_ARG_FIELDS_FILES_PRIORITY_HIGH:  torrentFile.fileList.rootItem.rpcFileIndexesHighPriority,
                                                      TR_ARG_FIELDS_FILES_PRIORITY_LOW: torrentFile.fileList.rootItem.rpcFileIndexesLowPriority,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES) }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTADD andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentAddedWithResult:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentAddedWithResult:json];
             });
     }];
    
}



- (void)addTorrentWithData:(NSData *)data priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSString *base64content = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_METAINFO : base64content,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES) }	
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTADD andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentAddedWithResult:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentAddedWithResult:json];
             });
     }];

}


- (void)renameTorrent:(int)torrentId withName:(NSString *)name andPath:(NSString *)path forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTSETNAME,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_NAME : name, TR_ARG_FIELDS_PATH: path }
                                  };
    NSLog(@"%@",requestVals);
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSETNAME andHandler:^(NSDictionary *json)
     {   NSLog(@"%@",json);
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentRenamed:withName:andPath:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentRenamed:torrentId withName:name andPath:path];
             });
     }];
}



- (void)addTorrentWithData:(NSData *)data
                  priority:(int)priority
          startImmidiately:(BOOL)startImmidiately
           indexesUnwanted:(NSArray*)idxUnwanted forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSString *base64content = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_METAINFO : base64content,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES),
                                                      TR_ARG_FIELDS_FILES_UNWANTED : idxUnwanted
                                                    }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTADD andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentAddedWithResult:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotTorrentAddedWithResult:json];
             });
     }];
    
}

- (void)addTorrentWithMagnet:(NSString *)magnetURLString priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{    
    NSDictionary *requestVals = @{
                                  TR_METHOD : TR_METHODNAME_TORRENTADD,
                                  TR_METHOD_ARGS : @{ TR_ARG_MAGNETFILENAME : magnetURLString,
                                                      TR_ARG_BANDWIDTHPRIORITY : @(priority),
                                                      TR_ARG_PAUSEONADD: startImmidiately ? @(NO):@(YES) }
                                  };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTADDURL andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotTorrentAddedWithMagnet:)])
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 [delegate gotTorrentAddedWithMagnet:magnetURLString];
             });
         }
         else if( delegate && [delegate respondsToSelector:@selector(gotTorrentAddedWithResult:)])
         {
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 [delegate gotTorrentAddedWithResult:json];
             });
         }
     }];
    
}

- (void)stopDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_FILES_UNWANTED : indexes } };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotFilesStoppedToDownload:forTorrentWithId:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotFilesStoppedToDownload:indexes forTorrentWithId:torrentId];
             });
     }];
}

- (void)resumeDownloadingFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], TR_ARG_FIELDS_FILES_WANTED : indexes } };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
                  if( delegate && [delegate respondsToSelector:@selector(gotFilesResumedToDownload:forTorrentWithId:)])
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [delegate gotFilesResumedToDownload:indexes forTorrentWithId:torrentId];
                      });
     }];
}

- (void)setPriority:(int)priority forFilesWithIndexes:(NSArray *)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSArray *argNames = @[TR_ARG_FIELDS_FILES_PRIORITY_LOW, TR_ARG_FIELDS_FILES_PRIORITY_NORMAL, TR_ARG_FIELDS_FILES_PRIORITY_HIGH];
    
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_TORRENTSET,
                                  TR_METHOD_ARGS : @{ TR_ARG_IDS : @[@(torrentId)], argNames[priority + 1] : indexes } };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_TORRENTSET andHandler:^(NSDictionary *json)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
            [self getAllFilesForTorrentWithId:torrentId forDelegate:delegate];
         });
         //         if( delegate && [delegate respondsToSelector:@selector(gotTorrentDeletedWithId:)])
         //             dispatch_async(dispatch_get_main_queue(), ^{
         //                 [delegate gotTorrentDeletedWithId:torrentId];
         //             });
     }];
}

- (void)getSessionInfoForDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{  // __strong typeof(delegate) delegate = _delegate;
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONGET };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_SESSIONGET andHandler:^(NSDictionary *json)
    {
         NSDictionary *sessionJSON = json[TR_RETURNED_ARGS];
        [TRSessionInfo setSharedTRSessionInfo:sessionJSON];
        TRSessionInfo *sessionInfo = [TRSessionInfo sharedTRSessionInfo];
        
        self->_sessionInfo = sessionInfo;
         if( delegate && [delegate respondsToSelector:@selector(gotSessionWithInfo:)])
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [delegate gotSessionWithInfo:sessionInfo];
                      });
    }];    
}

- (void)getSessionStatsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{  // __strong typeof(delegate) delegate = _delegate;
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSTATS };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_SESSIONSTATS andHandler:^(NSDictionary *json)
     {
         NSDictionary *sessionJSON = json[TR_RETURNED_ARGS];
         TRSessionStats *sessionStats = [TRSessionStats sessionStatsFromJSON:sessionJSON];

         if( delegate && [delegate respondsToSelector:@selector(gotSessionWithStats:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotSessionWithStats:sessionStats];
             });
     }];
}

- (void)setSessionWithSessionInfo:(TRSessionInfo *)info forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : info.jsonForRPC };
    
    [self makeRequest:requestVals forDelegate:delegate withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json)
     {
         if( delegate && [delegate respondsToSelector:@selector(gotSessionSetWithInfo:)] )
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotSessionSetWithInfo: info];
                 //[self getSessionInfo];
             });
     }];
}

// if rateKBs is 0 - limit is disabled
- (void)limitDownloadRateWithSpeed:(int)rateKbs forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    BOOL isEnabled = rateKbs > 0;
    
    NSDictionary* args;
    
    if( isEnabled )
        args = @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO), TR_ARG_SESSION_LIMITDOWNRATEENABLED : @(YES), TR_ARG_SESSION_LIMITDOWNRATE : @(rateKbs) };
    else
        args = @{ TR_ARG_SESSION_LIMITDOWNRATEENABLED : @(NO), TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO) };

    
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : args };
    
    [self makeRequest:requestVals  forDelegate:delegate withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json){
        [self getSessionInfoForDelegate:delegate];
    }];
}

// if rateKBs si 0 - limit is disabled
- (void)limitUploadRateWithSpeed:(int)rateKbs forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    BOOL isEnabled = rateKbs > 0;
   
    NSDictionary* args;
    
    if( isEnabled )
        args = @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO), TR_ARG_SESSION_LIMITUPRATEENABLED : @(YES), TR_ARG_SESSION_LIMITUPRATE : @(rateKbs) };
    else
        args = @{ TR_ARG_SESSION_LIMITUPRATEENABLED : @(NO), TR_ARG_SESSION_ALTLIMITRATEENABLED : @(NO) };

    
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET, TR_METHOD_ARGS : args };
    
    [self makeRequest:requestVals  forDelegate:delegate withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json){
        [self getSessionInfoForDelegate:delegate];
    }];
}

/// toggle alternative limits mode
- (void)toggleAltLimitMode:(BOOL)altLimitsEnabled forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_SESSIONSET,
                                   TR_METHOD_ARGS : @{ TR_ARG_SESSION_ALTLIMITRATEENABLED : @(altLimitsEnabled) } };
    
    [self makeRequest:requestVals  forDelegate:delegate withName:TR_METHODNAME_SESSIONSET andHandler:^(NSDictionary *json)
    {
        if( delegate && [delegate respondsToSelector:@selector(gotToggledAltLimitMode:)] )
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate gotToggledAltLimitMode:altLimitsEnabled];
            });
    }];
}

- (void)getFreeSpaceWithDownloadDir:(NSString *)downloadDir forDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    //__strong typeof(delegate) delegate = _delegate;
    NSDictionary *requestVals = @{TR_METHOD : TR_METHODNAME_FREESPACE,
                                  TR_METHOD_ARGS : @{ TR_ARG_FREESPACEPATH : downloadDir } };
    
    [self makeRequest:requestVals  forDelegate:delegate withName:TR_METHODNAME_FREESPACE andHandler:^(NSDictionary *json)
     {
         long long freeSizeBytes = [(NSNumber*)(json[TR_RETURNED_ARGS][TR_ARG_FREESPACESIZE]) longLongValue];

         NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
         formatter.allowsNonnumericFormatting = NO;
         NSString* freeSizeString = [formatter stringFromByteCount:freeSizeBytes];
         
         if( delegate && [delegate respondsToSelector:@selector(gotFreeSpaceString:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotFreeSpaceString:freeSizeString];
             });
     }];
}

- (void)portTestforDelegate:(id<RPCConnectorDelegate>) __strong  delegate
{
    NSDictionary *requestVals = @{ TR_METHOD : TR_METHODNAME_TESTPORT };
    
    [self makeRequest:requestVals  forDelegate:delegate withName:TR_METHODNAME_TESTPORT andHandler:^(NSDictionary *json)
     {
         BOOL portIsOpen = [(NSNumber*)(json[TR_RETURNED_ARGS][TR_ARG_PORTTESTPORTISOPEN]) boolValue];
         
         if( delegate && [delegate respondsToSelector:@selector(gotPortTestedWithSuccess:)])
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate gotPortTestedWithSuccess:portIsOpen];
             });
     }];
}

// perform request with JSON body and handler
- (void)makeRequest:(NSDictionary*)requestDict forDelegate:(id<RPCConnectorDelegate>)delegate withName:(NSString*)requestName andHandler:( void (^)( NSDictionary* )) dataHandler
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
    req.HTTPMethod = HTTP_REQUEST_METHOD;
    
    // add authorization header
    if( _authString )
        [req addValue:_authString forHTTPHeaderField: HTTP_AUTH_HEADER];
    
    if( _xTransSessionId )
        [req addValue: _xTransSessionId forHTTPHeaderField:HTTP_XTRANSID_HEADER];
    
    // JSON request
    //req.HTTPBody = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
    
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestDict options:kNilOptions error:NULL];
    req.timeoutInterval = self.requestTimeout;
    
    // preform one request at a time
//    if( _task )
//        [_task cancel];
    
    _task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        // code goes here
        if( error )
        {   NSMutableString *message = [NSMutableString stringWithFormat:@"%@",error.localizedDescription];
            if(requestDict[@"ids"])
                [message appendFormat:@" - %@",requestDict[@"ids"]];
            [self sendErrorMessage:message fromURL:req.URL toDelegate:delegate withRequestMethodName:requestName];
        }
        else
        {
            // check if if response not 200
            if( [response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSInteger statusCode = httpResponse.statusCode;
                
                if ( httpResponse.statusCode != HTTP_RESPONSE_OK )
                {
                    self.lastErrorMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
                    if( statusCode == HTTP_RESPONSE_UNAUTHORIZED )
                        self.lastErrorMessage = NSLocalizedString(@"You are unauthorized to access server", @"");
                    else if( statusCode == HTTP_RESPONSE_NEED_X_TRANS_ID )
                    {
                        self.xTransSessionId = httpResponse.allHeaderFields[HTTP_XTRANSID_HEADER];
                        [self makeRequest:requestDict forDelegate:delegate withName:requestName andHandler:dataHandler];
                        return;
                    }
                    
                    [self sendErrorMessage:[NSString stringWithFormat:@"%li %@", (long)statusCode, self.lastErrorMessage] fromURL:req.URL
                                toDelegate: delegate
                          withRequestMethodName:requestName];
                }
                else
                {
                    // response OK
                    // trying to deserialize answer data as JSNO object
                    NSDictionary *ansJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if( !ansJSON )
                    {
                        [self sendErrorMessage:NSLocalizedString(@"Server response wrong data", @"") fromURL:req.URL
                                    toDelegate:delegate withRequestMethodName:requestName];
                    }
                    // JSON is OK, trying to retrieve result of request it should be TR_RESULT_SUCCEED
                    else
                    {
                        NSString *result =  ansJSON[TR_RESULT];
                        if( !result )
                        {
                            [self sendErrorMessage:NSLocalizedString(@"Server failed to return data", @"") fromURL:req.URL
                                        toDelegate:delegate withRequestMethodName:requestName];
                        }
                        else if( ![result isEqualToString: TR_RESULT_SUCCEED] )
                        {
                            [self sendErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"Server failed to return data: %@", @""), result] fromURL:req.URL
                                  toDelegate:delegate withRequestMethodName:requestName];
                        }
                        else
                        {
                            // server returned SUCCESS
                            if(self->_task.state != NSURLSessionTaskStateCanceling && req.URL == self.url)
                                dataHandler( ansJSON );
                        }
                    }
                }
            }
        }
    }];
    
    [_task resume];
}

- (void)stopRequests
{
    if( _task )
        [_task cancel];
}

- (void)sendErrorMessage:(NSString*)message fromURL:(NSURL*)url toDelegate:(id<RPCConnectorDelegate>)delegate withRequestMethodName:(NSString*)methodName
{
    _lastErrorMessage = message;
    if( delegate && [delegate respondsToSelector:@selector(connector:completedRequestName:fromURL:withError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate connector:self completedRequestName:methodName fromURL:url withError:message ];
        });
    }
}


- (void)initWithURL:(NSURL*)url requestTimeout:(int)timeout
{
    [self stopRequests];
    _url = url;
    _requestTimeout = timeout;
    
    // create nsurlsession with our config parameters
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = _requestTimeout;
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    // add auth header if there is username
    _authString = nil;
    if( _url.user )
    {
        NSString *authStringToEncode64 = [NSString stringWithFormat:@"%@:%@", _url.user, _url.password];
        NSData *data = [authStringToEncode64 dataUsingEncoding:NSUTF8StringEncoding];
        _authString = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
    }
    //[self getSessionInfo];
}


+ (RPCConnector*)sharedConnector {
    
    static RPCConnector* _inst;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[RPCConnector alloc] init];
    });
    
    return _inst;
}


- (instancetype)initWithtURL:(NSURL*)url requestTimeout:(int)timeout
{
    self = [super init];
    if(self) {
        _url = url;
        _requestTimeout = timeout;
        
        // create nsurlsession with our config parameters
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = _requestTimeout;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        // add auth header if there is username
        _authString = nil;
        if( _url.user )
        {
            NSString *authStringToEncode64 = [NSString stringWithFormat:@"%@:%@", _url.user, _url.password];
            NSData *data = [authStringToEncode64 dataUsingEncoding:NSUTF8StringEncoding];
            _authString = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
        }
    }
    return self;
}


@end
