//
//  RPCConnector.h
//  TransmissionRPCClient
//
//  Main transmission RPC connector
//

#import <Foundation/Foundation.h>
#import "TRInfos.h"
#import "TRPeerInfo.h"
#import "TRFileInfo.h"
#import "TRSessionInfo.h"
#import "TrackerStat.h"
#import "FSDirectory.h"
#import "TorrentFile.h"

@class RPCConnector;

@protocol RPCConnectorDelegate <NSObject>

@optional - (void)connector:(RPCConnector *)cn completedRequestName:(NSString*)requestName fromURL:(NSURL*)url withError:(NSString*)errorMessage;
@optional - (void)gotAllTorrents:(TRInfos *)trInfos;
@optional - (void)gotRecentlyActiveTorrents:(TRInfos *)trInfos;
@optional - (void)gotTorrentDetailedInfo:(TRInfo*)torrentInfo;
@optional - (void)gotTorrentStopped;
@optional - (void)gotTorrentResumedWithId:(int)torrentId;
@optional - (void)gotTorrentsDeleted;
@optional - (void)gotTorrentsVerified;
@optional - (void)gotTorrentsReannounced;
@optional - (void)gotTorrentsMoved;
@optional - (void)gotTorrentAddedWithResult:(NSDictionary*)jsonResponse;
@optional - (void)gotTorrentAddedWithMagnet:(NSString*)magnet;
@optional - (void)gotAllPeers:(NSArray*)peerInfos withPeerStat:(TRPeerStat*)stat forTorrentWithId:(int)torrentId;
@optional - (void)gotAllFiles:(FSDirectory *)directory forTorrentWithId:(int)torrentId;
@optional - (void)gotAllFileStats:(NSArray*)fileStats forTorrentWithId:(int)torrentId;
@optional - (void)gotSessionWithInfo:(TRSessionInfo*)info;
@optional - (void)gotSessionSetWithInfo:(TRSessionInfo*)info;
@optional - (void)gotSessionWithStats:(TRSessionStats*)stats;
@optional - (void)gotFreeSpaceString:(NSString*)freeSpace;
@optional - (void)gotPortTestedWithSuccess:(BOOL)portIsOpen;
@optional - (void)gotAllTrackers:(NSArray*)trackerStats forTorrentWithId:(int)torrentId;
@optional - (void)gotTrackersAdded:(NSArray*)trackerURL forTorrentWithId:(int)torrentId;
@optional - (void)gotTrackerRemoved:(int)trackerId forTorrentWithId:(int)torrentId;
@optional - (void)gotSetSettingsForTorrentWithId:(int)torrentId;
@optional - (void)gotAllTorrentsStopped;
@optional - (void)gotAlltorrentsResumed;
@optional - (void)gotToggledAltLimitMode:(BOOL)altLimitEnabled;
@optional - (void)gotFilesStoppedToDownload:(NSArray *)filesIndexes forTorrentWithId:(int)torrentId;
@optional - (void)gotFilesResumedToDownload:(NSArray *)filesIndexes forTorrentWithId:(int)torrentId;
@optional - (void)gotMagnetURL:(NSString *)urlString forTorrentWithId:(int)torrentId;
@optional - (void)gotTorrentRenamed:(int)torrentId withName:(NSString *)name andPath:(NSString *)path;
@optional - (void)gotPiecesBitmap:(NSData *)piecesBitmap forTorrentWithId:(int)torrentId;

@end


@interface RPCConnector : NSObject

@property(nonatomic) NSString *lastErrorMessage;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic) int requestTimeout;
@property (strong, nonatomic) TRSessionInfo *sessionInfo;


/*!
 Method to update the RPCConnector properties.  Mainly used to initialize the shared connector.
 @param url - NSURL object with connection session information
 @param timeout - session request timeout (in seconds)
 */
- (void)initWithURL:(NSURL*)url requestTimeout:(int)timeout;


/*!
 Object instance initializer
 @param url - NSURL object with connection session information
 @param timeout - session request timeout (in seconds)
 @return RPCConnector instance initialized with session configuration according to passed parameters values
 */

- (instancetype)initWithtURL:(NSURL*)url requestTimeout:(int)timeout;


/*!
     Common Standard Share Connection (singleton)
     @return a common RPCConnector available for use through multiple interface components
 */
+ (RPCConnector*)sharedConnector;


/*!
 Method to request information for all Torrents.  You must implement the gotAllTorrents method of the RPCConnectorDelegate protocol to obtain the returned Torrents info.
 */
- (void)getAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

/*!
 Method to request information for only recently active Torrents.  You must implement the gotAllTorrents method of the RPCConnectorDelegate protocol to obtain the returned Torrents info.
 */
- (void)getRecentlyActiveTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;


/*!
    Method to request information for all Torrents.  Unlike the gotAllTorrents method, this method return the Torrents info in a synchronous way.
 */
-( TRInfos*)returnAllTorrents;


/*!
    Method to request the detailed information for a particular Torrent.  You must implement the gotTorrentDetailedInfo method of the RPCConnectorDelegate protocol to obtain the returned Torrent detailed info.
    @param torrentId - Torrent Id
 */
- (void)getDetailedInfoForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;


/*!
 Method to request the cancel any queue pending RPC request.
 */
- (void)stopRequests;



- (void)toggleAltLimitMode:(BOOL)altLimitsEnabled forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;


/*!
    Method to stop the current action (download, seed, wait, etc.) for a collection of Torrents.  Optionally, you can implement the gotTorrentsStopped method of the RPCConnectorDelegate protocol to take any action necessary action after the request was completed.
 @param torrentsId - Array of Torrents Ids to request the stop action
 */
- (void)stopTorrents:(NSArray*)torrentsId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;


- (void)stopAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)resumeTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)resumeNowTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)resumeAllTorrentsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)verifyTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)reannounceTorrent:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)deleteTorrentWithId:(NSArray*)torrentId deleteWithData:(BOOL)deleteWithData forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)moveTorrentQueue:(NSArray*)torrentId toPosition:(NSArray*)position forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)moveTorrentUp:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)moveTorrentDown:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)moveTorrentTop:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)moveTorrentBottom:(NSArray*)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;


- (void)addTorrentWithFile:(TorrentFile*)torrentFile priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)addTorrentWithData:(NSData*)data priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)addTorrentWithData:(NSData *)data priority:(int)priority startImmidiately:(BOOL)startImmidiately indexesUnwanted:(NSArray*)idxUnwanted forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)addTorrentWithMagnet:(NSString*)magnetURLString priority:(int)priority startImmidiately:(BOOL)startImmidiately forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)getAllPeersForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)getAllFilesForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)getAllFileStatsForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)getAllTrackersForTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)addTrackers:(NSArray*)trackerURL forTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)removeTracker:(int)trackerId forTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)stopDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)resumeDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)setPriority:(int)priority forFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)setSettings:(TRInfo*)settings forTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)getSessionInfoForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)getSessionStatsForDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)setSessionWithSessionInfo:(TRSessionInfo*)info forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)getFreeSpaceWithDownloadDir:(NSString*)downloadDir forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)portTestforDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)limitUploadRateWithSpeed:(int)rateKbs forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)limitDownloadRateWithSpeed:(int)rateKbs forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

- (void)getMagnetURLforTorrentWithId:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)renameTorrent:(int)torrentId withName:(NSString *)name andPath:(NSString *)path forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;
- (void)getPiecesBitMapForTorrent:(int)torrentId forDelegate:(id<RPCConnectorDelegate>) __strong  delegate;

@end


