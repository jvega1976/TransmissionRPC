//
//  GlobalConsts.h
//  TransmissionRPCClient
//
//  Constants using in all uiviewcontrolles
//

#import <Foundation/Foundation.h>

/*!
    Returns formatted localized string for count of bytes
    @param bytes - count of bytes
    @return string representation (localized)
 */
NSString* formatByteCount(long long bytes);


/*!
    Returns formatted localized string for count of bytes
    @param bytesPerSeconds - count of bytes per second
    @return string representation (localized)
 */
NSString* formatByteRate(long long bytesPerSeconds);


/*!
     Returns formatted localized date string
     @param intevalSince1970 - time interval in seconds
     @return formatted localized date/time string - long mode
 */
NSString* formatDateFrom1970(NSTimeInterval intevalSince1970);


/*!
     Returns formatted localized date string
     @param seconds - time interval in seconds
     @return formatted localized date/time string - short mode
 */
NSString* formatDateFrom1970Short(NSTimeInterval seconds);


/*!
    Returns formatted localized time string
    @param intervalSince1970 - time interval in seconds
    @return formatted localized time string (months, days, hours, minutes and seconds)
 */
NSString* formatHoursMinutes(NSTimeInterval intervalSince1970);
