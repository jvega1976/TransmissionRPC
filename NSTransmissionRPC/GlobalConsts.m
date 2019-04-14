//
//  GlobalConsts.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 05.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "GlobalConsts.h"

NSString* formatByteCount(long long byteCount)
{
    static NSByteCountFormatter *formatter = nil;
    
    if( !formatter )
    {
        formatter = [[NSByteCountFormatter alloc] init];
        formatter.allowsNonnumericFormatting = NO;
        formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    }
    
    if( byteCount == 0 )
        return  @"0 KB";
    
    return [formatter stringFromByteCount:byteCount];
}


NSString* formatByteRate(long long bytesPerSeconds)
{
    return [NSString stringWithFormat: @"%@/s",
            formatByteCount(bytesPerSeconds)];
}


NSString* formatDateFrom1970(NSTimeInterval seconds)
{
    static NSDateFormatter *formatter = nil;
    
    if( seconds == 0 )
        return @"";
    
    if( !formatter )
    {
        NSLocale *locale = [NSLocale currentLocale];
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = locale;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
    return [formatter stringFromDate:dt];
}


NSString* formatDateFrom1970Short(NSTimeInterval seconds)
{
    static NSDateFormatter *formatter = nil;
    
    if( seconds == 0 )
        return @"-";
    
    if( !formatter )
    {
        NSLocale *locale = [NSLocale currentLocale];
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = locale;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:seconds];
    return [formatter stringFromDate:dt];
}


NSString* formatHoursMinutes(NSTimeInterval seconds)
{
   NSDateComponentsFormatter *dateFormatter = [[NSDateComponentsFormatter alloc] init];
    dateFormatter.allowedUnits = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    dateFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
    dateFormatter.collapsesLargestUnit = NO;
    dateFormatter.maximumUnitCount = 3;
    NSString *secondsFormatted = [dateFormatter stringFromTimeInterval:seconds];
    return secondsFormatted;
}






