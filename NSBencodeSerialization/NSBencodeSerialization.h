//
//  NSBencodeSerialization.h
//  DALILite
//
//  Created by Carlo Tortorella on 16/12/13.
//  Copyright (c) 2013 Carlo Tortorella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBencodeSerialization : NSObject

+ (id)bencodedObjectWithData:(NSData *)data error:(NSError *__autoreleasing *)error;
+ (NSData *)dataWithBencodedObject:(id)object error:(NSError *__autoreleasing *)error;

@end
