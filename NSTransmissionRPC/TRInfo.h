//
//  TRInfo.h
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 28.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "transmission.h"


@interface TRInfo : NSObject

/*!
 Class Type convenient Initializer
 @param dict NSDictionary object (commonly in the JSON Transmission RPC specification  format) containing the detailed info for the Torrent object.
 @return A TRInfo object initialized with the content of the JSON data passed as parameter.
 */
+ (TRInfo *)infoFromJSON:(NSDictionary*)dict;


/*!
 Torrent Name
 */
@property(nonatomic,readonly) NSString*     name;
@property(nonatomic,readonly) float         percentsDone;
@property(nonatomic,readonly) NSString*     percentsDoneString;
@property(nonatomic,readonly) int           status;
@property(nonatomic,readonly) NSString*     statusString;

/*!
 @property Torrent Id
 */

@property(nonatomic,readonly) int           trId;

@property(nonatomic,readonly) long long     totalSize;
@property(nonatomic,readonly) NSString*     totalSizeString;
@property(nonatomic,readonly) long long     downloadedSize;
@property(nonatomic,readonly) NSString*     downloadedSizeString;
@property(nonatomic,readonly) long long     downloadedEver;
@property(nonatomic,readonly) NSString*     downloadedEverString;
@property(nonatomic,readonly) long long     uploadRate;
@property(nonatomic,readonly) NSString*     uploadRateString;
@property(nonatomic,readonly) long long     downloadRate;
@property(nonatomic,readonly) NSString*     downloadRateString;

@property(nonatomic,readonly) int           peersConnected;
@property(nonatomic,readonly) int           peersSendingToUs;
@property(nonatomic,readonly) int           peersGettingFromUs;
@property(nonatomic,readonly) long long     uploadedEver;
@property(nonatomic,readonly) NSString*     uploadedEverString;
@property(nonatomic,readonly) float         uploadRatio;

// statuses
@property(readonly)  BOOL                   isDownloading;
@property(readonly)  BOOL                   isWaiting;
@property(readonly)  BOOL                   isSeeding;
@property(readonly)  BOOL                   isStopped;
@property(readonly)  BOOL                   isChecking;
@property(readonly)  BOOL                   isError;
@property(readonly)  BOOL                   isFinished;

// detailed info
@property(nonatomic,readonly) NSString*     hashString;
@property(nonatomic,readonly) int           piecesCount;
@property(nonatomic,readonly) long long     pieceSize;
@property(nonatomic,readonly) NSString*     pieceSizeString;

@property(nonatomic,readonly) NSString*     comment;
@property(nonatomic,readonly) NSString*     downloadDir;

@property(nonatomic,readonly) NSString*     errorString;
@property(nonatomic,readonly) int           errorNumber;

@property(nonatomic,readonly) NSString*     creator;

@property(nonatomic,readonly) NSString*     dateCreatedString;
@property(nonatomic,readonly) NSDate*       dateAdded;
@property(nonatomic,readonly) NSString*     dateAddedString;
@property(nonatomic,readonly) NSDate*       dateDone;
@property(nonatomic,readonly) NSString*     dateDoneString;
@property(nonatomic,readonly) NSString*     dateLastActivityString;

@property(nonatomic,readonly) NSString*     downloadingTimeString;
@property(nonatomic,readonly) NSString*     seedingTimeString;
@property(nonatomic,readonly) NSString*     etaTimeString;

@property(nonatomic,readonly) NSString*     haveValidString;
@property(nonatomic,readonly) double        haveValid;
@property(nonatomic,readonly) NSString*     haveUncheckedString;

@property(nonatomic,readonly) float         recheckProgress;
@property(nonatomic,readonly) NSString*     recheckProgressString;

@property(nonatomic) int                    bandwidthPriority;
@property(nonatomic,readonly) NSString*     bandwidthPriorityString;


@property(nonatomic) BOOL                   honorsSessionLimits;
@property(nonatomic) int                    peerLimit;
@property(nonatomic) BOOL                   uploadLimitEnabled;
@property(nonatomic) int                    uploadLimit;
@property(nonatomic) BOOL                   downloadLimitEnabled;
@property(nonatomic) int                    downloadLimit;
@property(nonatomic) int                    seedIdleMode;
@property(nonatomic) int                    seedIdleLimit;
@property(nonatomic) int                    seedRatioMode;
@property(nonatomic) float                  seedRatioLimit;
@property(nonatomic) int                    queuePosition;
@property(nonatomic) long                   eta;

@property(nonatomic) NSString               *progressPercentString;
@property(nonatomic) float                  progressPercent;

@end
