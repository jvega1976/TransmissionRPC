//
//  TRSessionInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCConfigValues.h"

@interface TRSessionStats : NSObject

@property (nonatomic,readonly) int      activeTorrentCount;
@property (nonatomic,readonly) int      downloadSpeed;
@property (nonatomic,readonly) int      pausedTorrentCount;
@property (nonatomic,readonly) long      torrentCount;
@property (nonatomic,readonly) int      uploadSpeed;
@property (nonatomic,readonly) long      cumulativeUploadedBytes;
@property (nonatomic,readonly) long      cumulativedownloadedBytes;
@property (nonatomic,readonly) long      cumulativeFilesAdded;
@property (nonatomic,readonly) long      cumulativesessionCount;
@property (nonatomic,readonly) long long      cumulativeSecondsActive;
@property (nonatomic,readonly) long       currentUploadedBytes;
@property (nonatomic,readonly) long       currentdownloadedBytes;
@property (nonatomic,readonly) long       currentFilesAdded;
@property (nonatomic,readonly) long       currentsessionCount;
@property (nonatomic,readonly) long long  currentSecondsActive;

+ (TRSessionStats*)sessionStatsFromJSON:(NSDictionary*)dict;

@end



@interface TRSessionInfo : NSObject

+ (TRSessionInfo*)sessionInfoFromJSON:(NSDictionary*)dict;


@property(nonatomic) NSString      *transmissionVersion;
@property(nonatomic) NSString      *rpcVersion;
@property(nonatomic) NSString      *downloadDir;
@property(nonatomic) BOOL          incompletedDirEnabled;
@property(nonatomic) NSString      *incompletedDir;
@property(nonatomic) BOOL          scriptTorrentDoneEnabled;
@property(nonatomic) NSString      *scriptTorrentDoneFile;

@property(nonatomic) BOOL          downloadQueueEnabled;
@property(nonatomic) int           downloadQueueSize;
@property(nonatomic) BOOL          seedQueueEnabled;
@property(nonatomic) int           seedQueueSize;
@property(nonatomic) BOOL          queueStalledEnabled;
@property(nonatomic) int           queueStalledMinutes;


@property(nonatomic) BOOL          startDownloadingOnAdd;
@property(nonatomic) BOOL          trashOriginalTorrentFile;

@property(nonatomic) BOOL          upLimitEnabled;
@property(nonatomic) BOOL          downLimitEnabled;
@property(nonatomic) int           upLimitRate;
@property(nonatomic) int           downLimitRate;

@property(nonatomic) BOOL          seedRatioLimitEnabled;
@property(nonatomic) float         seedRatioLimit;

@property(nonatomic) BOOL          portForfardingEnabled;
@property(nonatomic) BOOL          portRandomAtStartEnabled;
@property(nonatomic) int           port;

@property(nonatomic) BOOL          UTPEnabled;
@property(nonatomic) BOOL          PEXEnabled;
@property(nonatomic) BOOL          LPDEnabled;
@property(nonatomic) BOOL          DHTEnabled;

@property(nonatomic) int           globalPeerLimit;
@property(nonatomic) int           torrentPeerLimit;

@property(nonatomic) NSString      *encryption;
@property(nonatomic) int           encryptionId;               // 0 - required, 1 - preffered, 2 - tolerated

@property(nonatomic) int           seedIdleLimit;
@property(nonatomic) BOOL          seedIdleLimitEnabled;

@property(nonatomic) BOOL          altLimitEnabled;
@property(nonatomic) int           altDownloadRateLimit;
@property(nonatomic) int           altUploadRateLimit;
@property(nonatomic) BOOL          altLimitTimeEnabled;
@property(nonatomic) int           altLimitTimeBegin;
@property(nonatomic) int           altLimitTimeEnd;
@property(nonatomic) int           altLimitDay;
@property(nonatomic) BOOL          altLimitSun;
@property(nonatomic) BOOL          altLimitMon;
@property(nonatomic) BOOL          altLimitTue;
@property(nonatomic) BOOL          altLimitWed;
@property(nonatomic) BOOL          altLimitThu;
@property(nonatomic) BOOL          altLimitFri;
@property(nonatomic) BOOL          altLimitSat;

@property(nonatomic) NSDate        *limitTimeBegin;
@property(nonatomic) NSDate        *limitTimeEnd;

@property(nonatomic) BOOL          addPartToUnfinishedFilesEnabled;

@property(nonatomic) BOOL blocklistEnabled;
@property(nonatomic) NSString *blocklistURL;

// get json from config
@property(nonatomic,readonly) NSDictionary* jsonForRPC;

+ (instancetype)sharedTRSessionInfo;

+ (void)setSharedTRSessionInfo:(NSDictionary*)json;

@end
