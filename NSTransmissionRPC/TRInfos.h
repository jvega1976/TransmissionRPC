//
//  TRInfos.h
//  TransmissionRPCClient
//
//  Holds an array of trInfo and implements usfule utility methods
//  for sorting/getting

#import <Foundation/Foundation.h>
#import "TRInfo.h"

// KVC methods names for later use




@interface TRInfos : NSObject

+ (TRInfos*)sharedTRInfos;

+ (TRInfos*)init;

-(void) setInfosFromArrayOfJSON:(NSArray*)jsonArray;

@property(nonatomic) NSMutableArray<TRInfo*> *items;


@property(nonatomic,readonly) long long totalUploadRate;
@property(nonatomic,readonly) long long totalDownloadRate;

@property(nonatomic,readonly) NSString* totalUploadRateString;
@property(nonatomic,readonly) NSString* totalDownloadRateString;
@property(nonatomic,readonly) NSString* totalDownloadSizeString;
@property(nonatomic,readonly) NSString* totalUploadSizeString;


@end