//
//  TRInfo.m
//  TransmissionRPCClient
//
//  Torrent info class

#import "TRInfo.h"
#import "RPCConfigValues.h"
#import "GlobalConsts.h"
#import "transmission.h"

@interface TRInfo()

@end

@implementation TRInfo

// convinience initializer
+ (TRInfo *)infoFromJSON:(NSDictionary *)dict
{
    TRInfo *info = [[TRInfo alloc] initFromJSON:dict];
    return info;
}

// close default initializer
- (instancetype)init
{
    self = [super init];
    return self;
    //@throw [NSException exceptionWithName:@"TRInfo" reason:@"TRInfo object should be initialized from class method +infoFromJSON:" userInfo:nil];
}

- (instancetype)initFromJSON:(NSDictionary*)dict
{
    self = [super init];
    
    if( self )
    {
        if( dict[TR_ARG_FIELDS_NAME] )
            _name = dict[TR_ARG_FIELDS_NAME];
        
        if( dict[TR_ARG_FIELDS_PERCENTDONE] )
        {
            _percentsDone = [dict[TR_ARG_FIELDS_PERCENTDONE] floatValue];
            _percentsDoneString = [NSString stringWithFormat:@"%03.2f%%", _percentsDone * 100.0f];
        }
        
        if( dict[TR_ARG_FIELDS_ID] )
            _trId  = [dict[TR_ARG_FIELDS_ID] intValue];;
        

        
        if( dict[TR_ARG_FIELDS_RECHECKPROGRESS] )
        {
            _recheckProgress = [dict[TR_ARG_FIELDS_RECHECKPROGRESS] floatValue];
            _recheckProgressString = [NSString stringWithFormat:@"%03.2f%%", _recheckProgress * 100.0f];
        }
        
        if( dict[TR_ARG_FIELDS_RATEUPLOAD] )
        {
            _uploadRate = [dict[TR_ARG_FIELDS_RATEUPLOAD] longLongValue];
            _uploadRateString = formatByteRate(_uploadRate);
        }
        
        if( dict[TR_ARG_FIELDS_RATEDOWNLOAD] )
        {
            _downloadRate = [dict[TR_ARG_FIELDS_RATEDOWNLOAD] longLongValue];

        }
        
        if( dict[TR_ARG_FIELDS_DOWNLOADEDEVER] )
        {
            _downloadedEver = [dict[TR_ARG_FIELDS_DOWNLOADEDEVER] longLongValue];
            _downloadedEverString = formatByteCount(_downloadedEver);
        }
        
        if( dict[TR_ARG_FIELDS_TOTALSIZE])
        {
            _totalSize  = [dict[TR_ARG_FIELDS_TOTALSIZE] longLongValue];
            _totalSizeString = formatByteCount(_totalSize);
            _downloadedSize = (long long)((double)_totalSize * _percentsDone);
            _downloadedSizeString = formatByteCount(_downloadedSize);
        }
        
        if( dict[TR_ARG_FIELDS_HAVEVALID] )
        {
            _haveValid = [dict[TR_ARG_FIELDS_HAVEVALID] longLongValue];
            _haveValidString = formatByteCount(_haveValid);
        }
        
        if( dict[TR_ARG_FIELDS_HAVEUNCHECKED] )
        {
            long long haveUnchecked = [dict[TR_ARG_FIELDS_HAVEUNCHECKED] longLongValue];
            _haveUncheckedString = formatByteCount(haveUnchecked);
        }
        
        if( dict[TR_ARG_FIELDS_UPLOADEDEVER] )
        {
            _uploadedEver = [dict[TR_ARG_FIELDS_UPLOADEDEVER] longLongValue];
            _uploadedEverString = formatByteCount(_uploadedEver);
        }
        
        if( dict[TR_ARG_FIELDS_UPLOADRATIO] )
        {
            _uploadRatio = [dict[TR_ARG_FIELDS_UPLOADRATIO] floatValue];
            if( _uploadRatio < 0 )
                _uploadRatio = 0;
        }
        
        if( dict[TR_ARG_FIELDS_PEERSCONNECTED] )
            _peersConnected = [dict[TR_ARG_FIELDS_PEERSCONNECTED] intValue];
        
        if( dict[TR_ARG_FIELDS_PEERSGETTINGFROMUS] )
            _peersGettingFromUs = [dict[TR_ARG_FIELDS_PEERSGETTINGFROMUS] intValue];
        
        if( dict[TR_ARG_FIELDS_PEERSSENDINGTOUS] )
            _peersSendingToUs = [dict[TR_ARG_FIELDS_PEERSSENDINGTOUS] intValue];
       
        if( dict[TR_ARG_FIELDS_CREATOR])
            _creator = dict[TR_ARG_FIELDS_CREATOR];
        
        if( dict[TR_ARG_FIELDS_ERRORNUM] )
            _errorNumber = [dict[TR_ARG_FIELDS_ERRORNUM] intValue];
        
        if(dict[TR_ARG_FIELDS_ERRORSTRING])
        {
            _errorString = dict[TR_ARG_FIELDS_ERRORSTRING];
            if (_errorString.length > 0)
            {
                if (_errorNumber == TR_STAT_TRACKER_ERROR || _errorNumber == TR_STAT_LOCAL_ERROR)
                    _isError = YES;
                else
                    _isError = NO;
            }
        }
        
        if(dict[TR_ARG_FIELDS_COMMENT])
            _comment = dict[TR_ARG_FIELDS_COMMENT];
        
        if( dict[TR_ARG_FIELDS_DOWNLOADDIR] )
            _downloadDir = dict[TR_ARG_FIELDS_DOWNLOADDIR];
        
        if(dict[TR_ARG_FIELDS_HASHSTRING])
            _hashString = dict[TR_ARG_FIELDS_HASHSTRING];
        
        if(dict[TR_ARG_FIELDS_PIECESIZE])
        {
            _pieceSize = [(NSNumber*)dict[TR_ARG_FIELDS_PIECESIZE] longLongValue];
            _pieceSizeString = formatByteCount(_pieceSize);
        }
        
        if( dict[TR_ARG_FIELDS_PIECECOUNT] )
            _piecesCount = [(NSNumber*)dict[TR_ARG_FIELDS_PIECECOUNT] intValue];
        
        if(dict[TR_ARG_FIELDS_DATECREATED])
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_DATECREATED] doubleValue];
            _dateCreatedString = formatDateFrom1970(seconds);
        }
        
        if(dict[TR_ARG_FIELDS_ACTIVITYDATE])
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_ACTIVITYDATE] doubleValue];
            _dateLastActivityString = formatDateFrom1970(seconds);
        }
        
        if(dict[TR_ARG_FIELDS_DONEDATE])
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_DONEDATE] doubleValue];
            _dateDoneString = formatDateFrom1970(seconds);
            _dateDone = [NSDate dateWithTimeIntervalSince1970:seconds];
        }
        
        if(dict[TR_ARG_FIELDS_ADDDATE])
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_ADDDATE] doubleValue];
            _dateAddedString = formatDateFrom1970(seconds);
            _dateAdded = (dict[TR_ARG_FIELDS_DONEDATE] == 0) ? nil : [NSDate dateWithTimeIntervalSince1970:seconds];
        }
 
        if( dict[TR_ARG_FIELDS_SECONDSSEEDING] )
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_SECONDSSEEDING] doubleValue];
            _seedingTimeString = formatHoursMinutes(seconds);
        }
        
        if( dict[TR_ARG_FIELDS_SECONDSDOWNLOADING] )
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_SECONDSDOWNLOADING] doubleValue];
            _downloadingTimeString  = formatHoursMinutes(seconds);
        }
        
        if( dict[TR_ARG_FIELDS_ETA] )
        {
            NSTimeInterval seconds = [dict[TR_ARG_FIELDS_ETA] doubleValue];
            _etaTimeString = (seconds > 0) ? formatHoursMinutes(seconds) :   NSLocalizedString(@" ", @"ETA time string");
            _eta = seconds;
        }
        
        if( dict[TR_ARG_FIELDS_BANDWIDTHPRIORITY] )
        {
            _bandwidthPriority = [dict[TR_ARG_BANDWIDTHPRIORITY] intValue];
            _bandwidthPriorityString = (_bandwidthPriority == 0 ) ? @"normal" : ( _bandwidthPriority == -1 ? @"low" : @"high" );
        }
        
        if( dict[TR_ARG_FIELDS_HONORSSESSIONLIMITS] )
            _honorsSessionLimits = [dict[TR_ARG_FIELDS_HONORSSESSIONLIMITS] boolValue];

        if( dict[TR_ARG_FIELDS_QUEUEPOSITION] )
            _queuePosition = [dict[TR_ARG_FIELDS_QUEUEPOSITION] intValue];
        
        if( dict[TR_ARG_FIELDS_UPLOADLIMITED] )
        {
            _uploadLimitEnabled = [dict[TR_ARG_FIELDS_UPLOADLIMITED] boolValue];
            _uploadLimit = [dict[TR_ARG_FIELDS_UPLOADLIMIT] intValue];
        }
        
        if( dict[TR_ARG_FIELDS_DOWNLOADLIMITED] )
        {
            _downloadLimitEnabled = [dict[TR_ARG_FIELDS_DOWNLOADLIMITED] boolValue];
            _downloadLimit = [dict[TR_ARG_FIELDS_DOWNLOADLIMIT] intValue];
        }
        
        if( dict[TR_ARG_FIELDS_SEEDIDLEMODE] )
        {
            _seedIdleMode = [dict[TR_ARG_FIELDS_SEEDIDLEMODE] intValue];
            _seedIdleLimit = [dict[TR_ARG_FIELDS_SEEDIDLELIMIT] intValue];
        }
        
        if( dict[TR_ARG_FIELDS_SEEDRATIOMODE] )
        {
            _seedRatioMode = [dict[TR_ARG_FIELDS_SEEDRATIOMODE] intValue];
            _seedRatioLimit = [dict[TR_ARG_FIELDS_SEEDRATIOLIMIT] floatValue];
        }
        
//        if( dict[TR_ARG_FIELDS_ISFINISHED] )
//            _isFinished = [dict[TR_ARG_FIELDS_ISFINISHED] boolValue];
        
        if( dict[TR_ARG_FIELDS_PEERLIMIT] )
        {
            _peerLimit = [dict[TR_ARG_FIELDS_PEERLIMIT] floatValue];
        }
        
        _progressPercent = _percentsDone;
        _progressPercentString = [NSString stringWithFormat:@"%f", _percentsDone];
        
        if( dict[TR_ARG_FIELDS_STATUS])
        {
            _status = [dict[TR_ARG_FIELDS_STATUS] intValue];
            
            _statusString = @"Unknown";
            if( _status == TR_STATUS_DOWNLOAD)
            {
                _isDownloading = YES;
                _statusString = NSLocalizedString(@"trDownloading", @"");
                _downloadRateString = [NSString stringWithFormat:NSLocalizedString(@"↓DL: %@", @""), formatByteRate(_downloadRate)];
                
                _uploadRateString =[NSString stringWithFormat:NSLocalizedString(@"↑UL: %@", @""), formatByteRate(_uploadRate)];
                _totalSizeString = [NSString stringWithFormat: NSLocalizedString( @"%@ of %@, uploaded %@ (Ratio %0.2f)", @"" ),
                                    _downloadedEverString,
                                    formatByteCount(_totalSize),
                                    _uploadedEverString,
                                    _uploadRatio];
            }
            
            if( _status == TR_STATUS_DOWNLOAD_WAIT)
            {
                _isWaiting = YES;
                _statusString = NSLocalizedString(@"trWaiting", @"");
                _downloadRateString = [NSString stringWithFormat:NSLocalizedString(@"↓DL: %@", @""), formatByteRate(_downloadRate)];
                
                _uploadRateString =[NSString stringWithFormat:NSLocalizedString(@"↑UL: %@", @""), formatByteRate(_uploadRate)];
                _totalSizeString = [NSString stringWithFormat: NSLocalizedString( @"%@ of %@, uploaded %@ (Ratio %0.2f)", @"" ),
                                    _downloadedEverString,
                                    formatByteCount(_totalSize),
                                    _uploadedEverString,
                                    _uploadRatio];
            }
            if( _status == TR_STATUS_CHECK)
            {
                _isChecking = YES;
                _statusString = NSLocalizedString(@"trChecking", @"");
                _progressPercent = _recheckProgress;
                _progressPercentString = [NSString stringWithFormat:@"%f", _recheckProgress];
            }
            if(_status == TR_STATUS_CHECK_WAIT) {
                _isWaiting = YES;
                 _statusString = NSLocalizedString(@"trWaitingCheck", @"");
            }
            if(_status == TR_STATUS_SEED_WAIT ){
                _isWaiting = YES;
                _statusString = NSLocalizedString(@"trWaitingSeed", @"");
            }
                
            if ( _status == TR_STATUS_SEED)
            {
                _isSeeding = YES;
                _statusString = NSLocalizedString(@"trSeeding", @"");
                _uploadRateString = [NSString stringWithFormat:NSLocalizedString(@"↑UL: %@", @""), formatByteRate(_uploadRate)];
                _totalSizeString = [NSString stringWithFormat: NSLocalizedString(@"%@, uploaded %@ (Ratio %0.2f)", @""),
                         _totalSizeString,
                         _uploadedEverString,
                         _uploadRatio];
            }
            
            if( _status == TR_STATUS_STOPPED )
            {
               
                _statusString = NSLocalizedString(@"trStopped", @"");
                _downloadRateString = NSLocalizedString(@"no activity", @"");
                _totalSizeString =[NSString stringWithFormat: NSLocalizedString(@"%@, uploaded %@ (Ratio %0.2f)", @""),
                          _downloadedSizeString,
                          _uploadedEverString,
                          _uploadRatio];
                if (_percentsDone == 1) {
                    _isFinished = YES;
                }
                else {
                     _isStopped = YES;
                }
            }
            
            if( _isError )
            {
                _statusString = NSLocalizedString(@"trError", @"");
                _totalSizeString = [NSString stringWithFormat: NSLocalizedString(@"%@ of %@, uploaded %@ (Ratio %0.2f)", @""), _downloadedSizeString, formatByteCount(_totalSize), _uploadedEverString, _uploadRatio];
            }
        }
     }
    
    return self;
}


@end
