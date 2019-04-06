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

@optional - (void)connector:(RPCConnector *)cn complitedRequestName:(NSString*)requestName withError:(NSString*)errorMessage;
@optional - (void)gotAllTorrents:(TRInfos *)trInfos;
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
@property (weak) id<RPCConnectorDelegate> delegate;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic) int requestTimeout;
@property (strong, nonatomic) TRSessionInfo *sessionInfo;

/*!
 Class type initializer (singleton)
 @return empty initialized RPCConnector instance
 */

+ (RPCConnector*)init;


/*!
     Common Standard Share Connection (singleton)
     @return a common RPCConnector available for use through multiple interface components
 */
+ (RPCConnector*)sharedConnector;


/*!
    Method to update the shared RPCConnector
    @param url - NSURL object with connection session information
    @param timeout - session request timeout (in seconds)
    @param delegate - delegate for RPCconnector
 */
- (void)setURL:(NSURL*)url requestTimeout:(int)timeout andDelegate:(id<RPCConnectorDelegate>)delegate;

/*!
 Method to request information for all Torrents.  You must implement the gotAllTorrents method of the RPCConnectorDelegate protocol to obtain the returned Torrents info.
 */
- (void)getAllTorrents;


/*!
    Method to request information for all Torrents.  Unlike the gotAllTorrents method, this method return the Torrents info in a synchronous way.
 */
-( TRInfos*)returnAllTorrents;


/*!
    Method to request the detailed information for a particular Torrent.  You must implement the gotTorrentDetailedInfo method of the RPCConnectorDelegate protocol to obtain the returned Torrent detailed info.
    @param torrentId - Torrent Id
 */
- (void)getDetailedInfoForTorrentWithId:(int)torrentId;


/*!
 Method to request the cancel any queue pending RPC request.
 */
- (void)stopRequests;



- (void)toggleAltLimitMode:(BOOL)altLimitsEnabled;


/*!
    Method to stop the current action (download, seed, wait, etc.) for a collection of Torrents.  Optionally, you can implement the gotTorrentsStopped method of the RPCConnectorDelegate protocol to take any action necessary action after the request was completed.
    @param torrenstId - Array of Torrents Ids to request the stop action
 */
- (void)stopTorrents:(NSArray*)torrentsId;


- (void)stopAllTorrents;
- (void)resumeTorrent:(NSArray*)torrentId;
- (void)resumeNowTorrent:(NSArray*)torrentId;
- (void)resumeAllTorrents;
- (void)verifyTorrent:(NSArray*)torrentId;
- (void)reannounceTorrent:(NSArray*)torrentId;
- (void)deleteTorrentWithId:(NSArray*)torrentId deleteWithData:(BOOL)deleteWithData;
- (void)moveTorrentQueue:(NSArray*)torrentId toPosition:(NSArray*)position;
- (void)moveTorrentUp:(NSArray*)torrentId;
- (void)moveTorrentDown:(NSArray*)torrentId;
- (void)moveTorrentTop:(NSArray*)torrentId;
- (void)moveTorrentBottom:(NSArray*)torrentId;


- (void)addTorrentWithFile:(TorrentFile*)torrentFile priority:(int)priority startImmidiately:(BOOL)startImmidiately;
- (void)addTorrentWithData:(NSData*)data priority:(int)priority startImmidiately:(BOOL)startImmidiately;
- (void)addTorrentWithData:(NSData *)data priority:(int)priority startImmidiately:(BOOL)startImmidiately indexesUnwanted:(NSArray*)idxUnwanted;

- (void)addTorrentWithMagnet:(NSString*)magnetURLString priority:(int)priority startImmidiately:(BOOL)startImmidiately;

- (void)getAllPeersForTorrentWithId:(int)torrentId;
- (void)getAllFilesForTorrentWithId:(int)torrentId;
- (void)getAllFileStatsForTorrentWithId:(int)torrentId;

- (void)getAllTrackersForTorrentWithId:(int)torrentId;
- (void)removeTracker:(int)trackerId forTorrent:(int)torrentId;

- (void)stopDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
- (void)resumeDownloadingFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
- (void)setPriority:(int)priority forFilesWithIndexes:(NSArray*)indexes forTorrentWithId:(int)torrentId;
- (void)setSettings:(TRInfo*)settings forTorrentWithId:(int)torrentId;

- (void)getSessionInfo;
- (void)getSessionStats;
- (void)setSessionWithSessionInfo:(TRSessionInfo*)info;
- (void)getFreeSpaceWithDownloadDir:(NSString*)downloadDir;
- (void)portTest;

- (void)limitUploadRateWithSpeed:(int)rateKbs;
- (void)limitDownloadRateWithSpeed:(int)rateKbs;

- (void)getMagnetURLforTorrentWithId:(int)torrentId;
- (void)renameTorrent:(int)torrentId withName:(NSString *)name andPath:(NSString *)path;
- (void)getPiecesBitMapForTorrent:(int)torrentId;

@end


