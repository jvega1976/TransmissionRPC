//
//  TRInfos.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 28.06.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "TRInfos.h"
#import "GlobalConsts.h"



@interface TRInfos()

  // holds trInfo items

@end

@implementation TRInfos

{
    NSMutableDictionary *_chache;
    long long           _totalUploadRate;
    long long           _totalDownloadRate;
    
}


+ (TRInfos*)sharedTRInfos {
    
    static TRInfos* _inst;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[TRInfos alloc] init];
    });
    
    return _inst;
}

+ (TRInfos*)init {
    TRInfos *infos = [[TRInfos alloc] init];
    return infos;
}

// close init method
- (instancetype)init
{
    self = [super init];
    
    if( self )
    {
        _items = [NSMutableArray array];
        _chache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

// init from array of json objects
- (void)setInfosFromArrayOfJSON:(NSArray*)jsonArray
{
    NSMutableArray *items = [NSMutableArray array];
    for( NSDictionary* d in jsonArray)
        [items addObject: [TRInfo infoFromJSON:d]];
    NSArray *sortdescs = [NSArray arrayWithObjects:[[NSSortDescriptor sortDescriptorWithKey:@"queuePosition" ascending:YES] reversedSortDescriptor],nil];
    [items sortUsingDescriptors:sortdescs];
    _items = items;
}

-(void) updateInfosWithArrayofJSON:(NSArray*)jsonArray {
    NSArray *sortdescs = [NSArray arrayWithObjects:[[NSSortDescriptor sortDescriptorWithKey:@"trId" ascending:YES] reversedSortDescriptor],nil];
    [_items sortUsingDescriptors:sortdescs];
    for( NSDictionary* d in jsonArray) {
        TRInfo *trInfo = [TRInfo infoFromJSON:d];
        NSInteger index = [_items indexOfObjectPassingTest:^BOOL(TRInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.trId == trInfo.trId)
                return TRUE;
            return FALSE;
        }];
        if (index == NSNotFound)
            [_items insertObject:trInfo atIndex:0];
        else
            [_items replaceObjectAtIndex:index withObject:trInfo];
    }
}

#define CHACHE_KEY_TOTALUPSTR   @"totalUpRateStr"
- (NSString *)totalUploadRateString
{
//    if( _chache[CHACHE_KEY_TOTALUPSTR] )
//        return _chache[CHACHE_KEY_TOTALUPSTR];
    
    long long c = 0;
    
    for( TRInfo* info in _items )
        c += info.uploadRate;
    
    NSString *str = formatByteRate(c);
    _chache[CHACHE_KEY_TOTALUPSTR] = str;
    
    _totalUploadRate = c;
    
    return str;
}

- (long long)totalUploadRate
{
    return self.totalUploadRateString ? _totalUploadRate : 0;
}

#define CHACHE_KEY_TOTALDOWNSTR   @"totalDownRateStr"
- (NSString *)totalDownloadRateString
{
 /*   if( _chache[CHACHE_KEY_TOTALDOWNSTR] )
        return _chache[CHACHE_KEY_TOTALDOWNSTR];
  */
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadRate;
    
    NSString *str = formatByteRate(c);
    _chache[CHACHE_KEY_TOTALDOWNSTR] = str;
    
    _totalDownloadRate = c;
    
    return str;
}

- (long long)totalDownloadRate
{
    return self.totalDownloadRateString ? _totalDownloadRate : 0;
}

#define CHACHE_KEY_TOTALDOWNSIZESTR   @"totalDownSize"
- (NSString *)totalDownloadSizeString
{
 //   if( _chache[CHACHE_KEY_TOTALDOWNSIZESTR] )
 //       return _chache[CHACHE_KEY_TOTALDOWNSIZESTR];
    
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.downloadedSize;
 
    NSString *str = formatByteCount(c);
    
    _chache[CHACHE_KEY_TOTALDOWNSIZESTR] = str;
    
    return str;
}

#define CHACHE_KEY_TOTALUPSIZESTR   @"totalUpSize"
- (NSString *)totalUploadSizeString
{
//    if( _chache[CHACHE_KEY_TOTALUPSIZESTR] )
//        return _chache[CHACHE_KEY_TOTALUPSIZESTR];
    
    long long c = 0;
    for( TRInfo* info in _items )
        c += info.uploadedEver;
 
    NSString *str = formatByteCount(c);
    
    _chache[CHACHE_KEY_TOTALUPSIZESTR] = str;
    
    return str;
}

@end
