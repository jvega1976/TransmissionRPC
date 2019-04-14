//
//  TRSessionInfo.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRSessionInfo.h"
#import "GlobalConsts.h"

#define ENCRYPTION_ID_REQUIRED   @"required"
#define ENCRYPTION_ID_PREFFERED  @"preffered"
#define ENCRYPTION_ID_TOLERATED  @"tolerated"

@interface TRSessionStats()

@end

@implementation TRSessionStats

+ (TRSessionStats *)sessionStatsFromJSON:(NSDictionary *)dict
{
    return [[TRSessionStats alloc] initSessionStatsFromJSON:dict];
}

- (instancetype)initSessionStatsFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self )
        return self;
    _activeTorrentCount = [dict[TR_ARG_SESSION_ACTIVETORRENTCOUNT] intValue];
    _downloadSpeed = [dict[TR_ARG_SESSION_DOWNSPEED] intValue];
    _pausedTorrentCount = [dict[TR_ARG_SESSION_PAUSEDCOUNT] intValue];
    _torrentCount = [dict[TR_ARG_SESSION_TORRENTCOUNT] intValue];
    _uploadSpeed = [dict[TR_ARG_SESSION_UPLOADSPEED] intValue];
    NSDictionary *cumulativeStats = dict[TR_ARG_SESSION_CUMULATIVESTATS];
    _cumulativeUploadedBytes = [cumulativeStats[TR_ARG_SESSION_UPLOADEDBYTES] longValue];
    _cumulativedownloadedBytes = [cumulativeStats[TR_ARG_SESSION_DOWNLOADEDBYTES] longValue];
    _cumulativeFilesAdded = [cumulativeStats[TR_ARG_SESSION_FILESADDED] longValue];
    _cumulativesessionCount = [cumulativeStats[TR_ARG_SESSION_SEESIONCOUNT] longValue];
    _cumulativeSecondsActive =  [cumulativeStats[TR_ARG_SESSION_SECONDSACCTIVE] longLongValue];
    NSDictionary *currentStats = dict[TR_ARG_SESSION_CURRENTSTATS];
    _currentUploadedBytes = [currentStats[TR_ARG_SESSION_UPLOADEDBYTES] longValue];
    _currentdownloadedBytes = [currentStats[TR_ARG_SESSION_DOWNLOADEDBYTES] longValue];
    _currentFilesAdded = [currentStats[TR_ARG_SESSION_FILESADDED] longValue];
    _currentsessionCount = [currentStats[TR_ARG_SESSION_SEESIONCOUNT] longValue];
    _currentSecondsActive =  [currentStats[TR_ARG_SESSION_SECONDSACCTIVE] longLongValue];
    
    return self;
}



@end

@interface TRSessionInfo()

@end

@implementation TRSessionInfo

{
    int _encryptionId;
    NSMutableArray *_selectedDays;
}

-(void)fillSelectedDays {
    NSUInteger dec = _altLimitDay;
    for (NSUInteger i=0; i < 7 ; i++) {
        [_selectedDays setObject:(dec % 2) ? @(YES) : @(NO) atIndexedSubscript:i];
        dec = dec/2;
    }
    
}

+ (TRSessionInfo *)sessionInfoFromJSON:(NSDictionary *)dict
{
    return [[TRSessionInfo alloc] initSessionInfoFromJSON:dict];
}


- (instancetype)initSessionInfoFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( !self )
        return self;
 
    _selectedDays = [NSMutableArray arrayWithArray:@[@(NO),@(NO),@(NO),@(NO),@(NO),@(NO),@(NO)]];
    _altLimitDay = 0;
    
    _transmissionVersion =  [NSString stringWithFormat:@"Vers: %@", dict[TR_ARG_SESSION_VERSION]];
    _rpcVersion = [NSString stringWithFormat: NSLocalizedString(@"RPC: %@(min supported %@)", @"RPC min verson supported"),
                   dict[TR_ARG_SESSION_RPCVER], dict[TR_ARG_SESSION_RPCVERMIN]];
    
    _downloadDir = dict[TR_ARG_SESSION_DOWNLOADDIR];
    _startDownloadingOnAdd = [dict[TR_ARG_SESSION_STARTONADD] boolValue];
    _upLimitEnabled = [dict[TR_ARG_SESSION_LIMITUPRATEENABLED] boolValue];
    _downLimitEnabled = [dict[TR_ARG_SESSION_LIMITDOWNRATEENABLED] boolValue];
    _upLimitRate = [dict[TR_ARG_SESSION_LIMITUPRATE] intValue];
    _downLimitRate = [dict[TR_ARG_SESSION_LIMITDOWNRATE] intValue];
    
    _seedRatioLimitEnabled = [dict[TR_ARG_SESSION_SEEDRATIOLIMITENABLED] boolValue];
    _seedRatioLimit = [dict[TR_ARG_SESSION_SEEDRATIOLIMIT] floatValue];
    
    _portForfardingEnabled = [dict[TR_ARG_SESSION_PORTFORWARDENABLED] boolValue];
    _portRandomAtStartEnabled = [dict[TR_ARG_SESSION_PORTRANDOMONSTART] boolValue];
    _port = [dict[TR_ARG_SESSION_PORT] intValue];
    
    _UTPEnabled = [dict[TR_ARG_SESSION_UTPENABLED] boolValue];
    _PEXEnabled = [dict[TR_ARG_SESSION_PEXENABLED] boolValue];
    _LPDEnabled = [dict[TR_ARG_SESSION_LPDENABLED] boolValue];
    _DHTEnabled = [dict[TR_ARG_SESSION_DHTENABLED] boolValue];
    
    _globalPeerLimit = [dict[TR_ARG_SESSION_PEERLIMITTOTAL] intValue];
    _torrentPeerLimit = [dict[TR_ARG_SESSION_PEERLIMITPERTORRENT] intValue];
    
    _encryption = dict[TR_ARG_SESSION_ENRYPTION];
    
    _seedIdleLimit = [dict[TR_ARG_SESSION_IDLESEEDLIMIT] intValue];
    _seedIdleLimitEnabled = [dict[TR_ARG_SESSION_IDLELIMITENABLED] boolValue];
    
    _altLimitEnabled = [dict[TR_ARG_SESSION_ALTLIMITRATEENABLED] boolValue];
    _altDownloadRateLimit = [dict[TR_ARG_SESSION_ALTLIMIDOWNRATE] intValue];
    _altUploadRateLimit = [dict[TR_ARG_SESSION_ALTLIMITUPRATE] intValue];
    
    _altLimitTimeEnabled = [dict[TR_ARG_SESSION_ALTLIMITTIMEENABLED] boolValue];
    _altLimitTimeBegin = [dict[TR_ARG_SESSION_ALTLIMITTIMEBEGIN] intValue];
    _altLimitTimeEnd = [dict[TR_ARG_SESSION_ALTLIMITTIMEEND] intValue];
    _altLimitDay = [dict[TR_ARG_SESSION_ALTLIMITTIMEDAY] intValue];
    
    _addPartToUnfinishedFilesEnabled = [dict[TR_ARG_SESSION_RENAMEPARTIAL] boolValue];
    _incompletedDirEnabled = [dict[TR_ARG_SESSION_INCOMPLETEDIRENABLED] boolValue];
    _incompletedDir =  dict[TR_ARG_SESSION_INCOMPLETEDIR];
    _trashOriginalTorrentFile = [dict[TR_ARG_SESSION_TRASHFILES] boolValue];
    _scriptTorrentDoneEnabled =  [dict[TR_ARG_SESSION_SCRIPTDONEENABLED] boolValue];
    _scriptTorrentDoneFile = dict[TR_ARG_SESSION_SCRIPTDONEFILE];
    _downloadQueueSize = [dict[TR_ARG_SESSION_DOWNLOADQUEUESIZE] intValue];
    _downloadQueueEnabled = [dict[TR_ARG_SESSION_DOWNLOADQUEUEENABLED] boolValue];
    _seedQueueEnabled = [dict[TR_ARG_SESSION_SEEDQUEUEENABLED] boolValue];
    _seedQueueSize = [dict[TR_ARG_SESSION_SEEDQUEUESIZE] intValue];
    _queueStalledEnabled = [dict[TR_ARG_SESSION_QUEUESTALLEDENABLED] boolValue];
    _queueStalledMinutes = [dict[TR_ARG_SESSION_QUEUESTALLEDMINUTES] intValue];
    _blocklistEnabled = [dict[TR_ARG_SESSION_BLOCKLISTENABLED] boolValue];
    _blocklistURL = dict[TR_ARG_SESSION_BLOCKLIST];
    
    [self fillSelectedDays];
    
    return self;
}

// return JSON for RPC session-set
- (NSDictionary *)jsonForRPC
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    dict[TR_ARG_SESSION_STARTONADD] = @(_startDownloadingOnAdd);
    dict[TR_ARG_SESSION_RENAMEPARTIAL] = @(_addPartToUnfinishedFilesEnabled);
    
    dict[TR_ARG_SESSION_LIMITUPRATEENABLED] = @(_upLimitEnabled);
    if( _upLimitEnabled )
        dict[TR_ARG_SESSION_LIMITUPRATE] = @(_upLimitRate);
    
    dict[TR_ARG_SESSION_LIMITDOWNRATEENABLED] = @(_downLimitEnabled);
    if( _downLimitEnabled )
        dict[TR_ARG_SESSION_LIMITDOWNRATE] = @(_downLimitRate);
    
    dict[TR_ARG_SESSION_SEEDRATIOLIMITENABLED] = @(_seedIdleLimitEnabled);
    
    if( _seedIdleLimitEnabled )
        dict[TR_ARG_SESSION_SEEDRATIOLIMIT] = @(_seedRatioLimit);
    
    dict[TR_ARG_SESSION_PORTFORWARDENABLED] = @(_portForfardingEnabled);
    dict[TR_ARG_SESSION_PORTRANDOMONSTART] = @(_portRandomAtStartEnabled);
    dict[TR_ARG_SESSION_PORT] = @(_port);
    
    dict[TR_ARG_SESSION_UTPENABLED] = @(_UTPEnabled);
    dict[TR_ARG_SESSION_PEXENABLED] = @(_PEXEnabled);
    dict[TR_ARG_SESSION_LPDENABLED] = @(_LPDEnabled);
    dict[TR_ARG_SESSION_DHTENABLED] = @(_DHTEnabled);
    
    dict[TR_ARG_SESSION_PEERLIMITTOTAL] = @(_globalPeerLimit);
    dict[TR_ARG_SESSION_PEERLIMITPERTORRENT] = @(_torrentPeerLimit);
  
    dict[TR_ARG_SESSION_ENRYPTION] = _encryption;
    
    dict[TR_ARG_SESSION_IDLELIMITENABLED] = @(_seedIdleLimitEnabled);
    
    if( _seedIdleLimitEnabled )
        dict[TR_ARG_SESSION_IDLESEEDLIMIT] = @(_seedIdleLimit);
    
    dict[TR_ARG_SESSION_ALTLIMITRATEENABLED] = @(_altLimitEnabled);
    if( _altLimitEnabled )
    {
        dict[TR_ARG_SESSION_ALTLIMIDOWNRATE] = @(_altDownloadRateLimit);
        dict[TR_ARG_SESSION_ALTLIMITUPRATE] = @(_altUploadRateLimit);
    }
    
    dict[TR_ARG_SESSION_DOWNLOADDIR] = _downloadDir;
    
    dict[TR_ARG_SESSION_ALTLIMITTIMEENABLED] = @(_altLimitTimeEnabled);
    dict[TR_ARG_SESSION_ALTLIMITTIMEBEGIN] = @(_altLimitTimeBegin);
    dict[TR_ARG_SESSION_ALTLIMITTIMEEND] = @(_altLimitTimeEnd);
    dict[TR_ARG_SESSION_ALTLIMITTIMEDAY] = @(_altLimitDay);
    dict[TR_ARG_SESSION_RENAMEPARTIAL] = @(_addPartToUnfinishedFilesEnabled);
    dict[TR_ARG_SESSION_INCOMPLETEDIRENABLED] = @(_incompletedDirEnabled);
    dict[TR_ARG_SESSION_INCOMPLETEDIR] = _incompletedDir;
    dict[TR_ARG_SESSION_TRASHFILES]  = @(_trashOriginalTorrentFile);
    dict[TR_ARG_SESSION_SCRIPTDONEENABLED]= @(_scriptTorrentDoneEnabled);
    dict[TR_ARG_SESSION_SCRIPTDONEFILE] =  _scriptTorrentDoneFile;
    dict[TR_ARG_SESSION_DOWNLOADQUEUESIZE] = @(_downloadQueueSize);
    dict[TR_ARG_SESSION_DOWNLOADQUEUEENABLED] =  @(_downloadQueueEnabled);
    dict[TR_ARG_SESSION_SEEDQUEUEENABLED] = @(_seedQueueEnabled);
    dict[TR_ARG_SESSION_SEEDQUEUESIZE] = @(_seedQueueSize);
    dict[TR_ARG_SESSION_QUEUESTALLEDENABLED] = @(_queueStalledEnabled);
    dict[TR_ARG_SESSION_QUEUESTALLEDMINUTES] = @(_queueStalledMinutes);
    
   
    return dict;
}

- (int)encryptionId
{
    _encryptionId = [_encryption isEqualToString:ENCRYPTION_ID_REQUIRED] ? 0 : ( [_encryption isEqualToString:ENCRYPTION_ID_PREFFERED] ? 1 : 2 );
    return _encryptionId;
}

- (void)setEncryptionId:(int)encryptionId
{
    _encryptionId = encryptionId;
    _encryption = _encryptionId == 0 ? ENCRYPTION_ID_REQUIRED : ( _encryptionId == 1 ? ENCRYPTION_ID_PREFFERED : ENCRYPTION_ID_TOLERATED );
}


-(BOOL)altLimitSun {
    return [[_selectedDays objectAtIndex:0] boolValue];
}

-(BOOL)altLimitMon {
    return [[_selectedDays objectAtIndex:1] boolValue];
}

-(BOOL)altLimitTue {
    return [[_selectedDays objectAtIndex:2] boolValue];
}

-(BOOL)altLimitWed {
    return [[_selectedDays objectAtIndex:3] boolValue];
}

-(BOOL)altLimitThu {
    return [[_selectedDays objectAtIndex:4] boolValue];
}

-(BOOL)altLimitFri {
    return [[_selectedDays objectAtIndex:5] boolValue];
}

-(BOOL)altLimitSat {
    return [[_selectedDays objectAtIndex:6] boolValue];
}


-(void)setAltLimitDay:(int)altLimitDay {
    _altLimitDay = altLimitDay;
    [self fillSelectedDays];
}

-(void)deriveAltLimitDay {
    int tmpLimitDay = 0;
    for(NSUInteger i=0; i < 7; i++) {
        int n = pow(2,i);
        BOOL isSel = [_selectedDays[i] boolValue];
        int x = (isSel)?1:0;
        tmpLimitDay = tmpLimitDay + (x*n);
    }
    [self setAltLimitDay:tmpLimitDay];
}

-(void)setAltLimitSun:(BOOL)altLimitSun {
    [_selectedDays setObject:@(altLimitSun) atIndexedSubscript:0];
    [self deriveAltLimitDay];
}

-(void)setAltLimitMon:(BOOL)altLimitMon {
    [_selectedDays setObject:@(altLimitMon) atIndexedSubscript:1];
    [self deriveAltLimitDay];
}

-(void)setAltLimitTue:(BOOL)altLimitTue{
    [_selectedDays setObject:@(altLimitTue) atIndexedSubscript:2];
    [self deriveAltLimitDay];
}

-(void)setAltLimitWed:(BOOL)altLimitWed {
    [_selectedDays setObject:@(altLimitWed) atIndexedSubscript:3];
    [self deriveAltLimitDay];
}

-(void)setAltLimitThu:(BOOL)altLimitThu {
    [_selectedDays setObject:@(altLimitThu) atIndexedSubscript:4];
    [self deriveAltLimitDay];
}

-(void)setAltLimitFri:(BOOL)altLimitFri {
    [_selectedDays setObject:@(altLimitFri) atIndexedSubscript:5];
    [self deriveAltLimitDay];
}

-(void)setAltLimitSat:(BOOL)altLimitSat {
    [_selectedDays setObject:@(altLimitSat) atIndexedSubscript:6];
    [self deriveAltLimitDay];
}


- (void)setLimitTimeBegin:(NSDate *)limitTimeBegin {
    NSDate *dt = limitTimeBegin;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *c = [cal components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:dt];
    
    _altLimitTimeBegin = (int)(c.hour * 60 + c.minute);
}



- (void)setLimitTimeEnd:(NSDate *)limitTimeEnd {

    NSDate *dt = limitTimeEnd;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *c = [cal components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:dt];
    
    _altLimitTimeEnd =  (int)(c.hour * 60 + c.minute);
}

-(NSDate*)limitTimeBegin {
    
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *cp = [c components:NSUIntegerMax fromDate:[NSDate date]];
    cp.hour = _altLimitTimeBegin/ 60;
    cp.minute = _altLimitTimeBegin % 60;
    
    return [c dateFromComponents:cp];
}


-(NSDate*)limitTimeEnd {
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *cp = [c components:NSUIntegerMax fromDate:[NSDate date]];
    cp.hour = _altLimitTimeEnd / 60;
    cp.minute = _altLimitTimeEnd % 60;
    
    return [c dateFromComponents:cp];
}


static TRSessionInfo *sessionInfoShared = nil;


+(instancetype)sharedTRSessionInfo {
    return sessionInfoShared;
}


+ (void)setSharedTRSessionInfo:(NSDictionary*)json
{
    static NSDictionary *jsonCurrent = nil;
    
    if(![json isEqual:jsonCurrent]){
        jsonCurrent = [json copy];
        sessionInfoShared = [TRSessionInfo sessionInfoFromJSON:json];
    }
    
}

@end






