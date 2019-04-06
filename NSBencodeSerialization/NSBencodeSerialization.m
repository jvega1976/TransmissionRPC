//
//  NSBencodeSerialization.m
//  DALILite
//
//  Created by Carlo Tortorella on 16/12/13.
//  Copyright (c) 2013 Carlo Tortorella. All rights reserved.
//

#import "NSBencodeSerialization.h"
#import "M13OrderedDictionary.h"

@implementation NSBencodeSerialization

+ (id)bencodedObjectWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
	uint64_t start = 0;
	return [NSBencodeSerialization bencodedObjectWithData:data startingAt:&start error:error];
}

+ (NSData *)dataWithBencodedObject:(id)object error:(NSError *__autoreleasing *)error
{
	NSMutableData * retVal = NSMutableData.new;
	if ([object respondsToSelector:@selector(objectForKey:)])
	{
		NSArray * keys = [[object allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]])
			{
				return [obj1 caseInsensitiveCompare:obj2];
			}
			return NSOrderedSame;
		}];

		[retVal appendData:[@"d" dataUsingEncoding:NSASCIIStringEncoding]];
		for (id key in keys)
		{
			[retVal appendData:[NSBencodeSerialization dataWithBencodedObject:key error:error]];
			[retVal appendData:[NSBencodeSerialization dataWithBencodedObject:[object objectForKey:key] error:error]];
		}
		[retVal appendData:[@"e" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	else if ([object isKindOfClass:[NSArray class]])
	{
		[retVal appendData:[@"l" dataUsingEncoding:NSASCIIStringEncoding]];
		for (id value in object)
		{
			[retVal appendData:[NSBencodeSerialization dataWithBencodedObject:value error:error]];
		}
		[retVal appendData:[@"e" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	else if ([object isKindOfClass:[NSNumber class]])
	{
		[retVal appendData:[[NSString stringWithFormat:@"i%llie", [object longLongValue]] dataUsingEncoding:NSASCIIStringEncoding]];
	}
	else if ([object isKindOfClass:[NSString class]])
	{
		[retVal appendData:[[NSString stringWithFormat:@"%lu:%@", (unsigned long)[object length], object] dataUsingEncoding:NSASCIIStringEncoding]];
	}
	else if ([object isKindOfClass:[NSData class]])
	{
		[retVal appendData:[[NSString stringWithFormat:@"%lu:", (unsigned long)[object length]] dataUsingEncoding:NSASCIIStringEncoding]];
		[retVal appendData:object];
	}
	else if ([object isKindOfClass:[NSNull class]])
	{
		[retVal appendData:[@"4:null" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	else
	{
		if (error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"An unexpected object of class %@ was encountered. This object was not encoded and the returned data may not be bencode compliant.", [object class]]}];
		}
	}
	return retVal;
}

+ (M13OrderedDictionary *)bencodedDictionaryWithData:(NSData *)data startingAt:(uint64_t *)start error:(NSError *__autoreleasing *)error
{
	++*start;
	NSMutableOrderedDictionary * dict = NSMutableOrderedDictionary.new;
	while (*start < data.length && ((const char *)data.bytes)[*start] != 'e')
	{
		id key = [NSBencodeSerialization bencodedObjectWithData:data startingAt:start error:error];
		id value = [NSBencodeSerialization bencodedObjectWithData:data startingAt:start error:error];
		if (key && value && ([key isKindOfClass:NSData.class] || [key isKindOfClass:NSString.class]))
		{
			[dict setObject:value forKey:key];
		}
		else
		{
			if (![key isKindOfClass:NSData.class] && ![key isKindOfClass:NSString.class])
			{
				if (error && !*error)
				{
					*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid type for dictionary key (%@), needs to be a string", [key  class]]}];
					*start = data.length;
				}
			}
			else
			{
				if (error && !*error)
				{
					*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Mismatched count of keys and values"}];
					*start = data.length;
				}
			}
			break;
		}
	}
	if (((const char *)data.bytes)[*start] != 'e')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No terminating e found for dictionary"}];
			*start = data.length;
		}
	}
	++*start;
	return dict;
}

+ (NSArray *)bencodedListWithData:(NSData *)data startingAt:(uint64_t *)start error:(NSError *__autoreleasing *)error
{
	++*start;
	NSMutableArray * list = NSMutableArray.new;
	while (*start < data.length && ((const char *)data.bytes)[*start] != 'e')
	{
		id value = [NSBencodeSerialization bencodedObjectWithData:data startingAt:start error:error];
		if (value)
		{
			[list addObject:value];
		}
	}
	if (((const char *)data.bytes)[*start] != 'e')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No terminating e found for list"}];
		}
	}
	++*start;
	return list;
}

+ (id)bencodedStringWithData:(NSData *)data startingAt:(uint64_t *)start error:(NSError *__autoreleasing *)error
{
	id retVal = nil;
	uint64_t length = strtoull(((const char *)data.bytes) + *start, NULL, 10);
	uint8_t numLen = length ? ceil(log10(length + 1)) : 1;

	if (((const char *)data.bytes)[*start] == '-')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Encountered string of negative length"}];
		}
		*start = data.length;
		return @"";
	}
	else if (((const char *)data.bytes)[*start + numLen] != ':')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expected terminating ':' for string length notation at index %llu in bencoded data, instead found '%c'", *start + numLen, ((const char *)data.bytes)[*start + numLen]]}];
		}
		*start = data.length;
		return @"";
	}

	*start += numLen + 1;
	if (*start + length <= data.length)
	{
		NSData * option2 = [NSData dataWithBytes:data.bytes + *start length:(NSUInteger)length];
		NSString * option1 = [NSString.alloc initWithData:option2 encoding:NSASCIIStringEncoding];
		retVal = option1;
		if (strlen([option1 UTF8String]) != option2.length)
		{
			retVal = option2;
		}
		else
		{
			for (uint64_t i = 0; i < strlen(option1.UTF8String); i++)
			{
				if (option1.UTF8String[i] <= 0)
				{
					retVal = option2;
					break;
				}
			}
		}
	}
	*start += length;
	return retVal;
}

+ (NSNumber *)bencodedIntegerWithData:(NSData *)data startingAt:(uint64_t *)start error:(NSError *__autoreleasing *)error
{
	++*start;
	NSMutableString * number = NSMutableString.new;
	char currentChar = ((const char *)data.bytes)[*start];
	if (currentChar == '-')
	{
		[number appendFormat:@"%c", ((const char *)data.bytes)[*start]];
		currentChar = ((const char *)data.bytes)[++*start];
	}

	while ((currentChar >= '0' && currentChar <= '9') || currentChar == '.')
	{
		[number appendFormat:@"%c", ((const char *)data.bytes)[*start]];
		currentChar = ((const char *)data.bytes)[++*start];
	}
	if (currentChar != 'e')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Expected terminating 'e' for integer at index %llu in bencoded data, instead found '%c'", *start, currentChar]}];
		}
		*start = data.length;
	}
	else if ([number isEqual:@"-0"])
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Encountered '-0', this is an illegal value in bencoding"}];
		}
		*start = data.length;
	}
	else if (number.length > 1 && [number characterAtIndex:0] == '0')
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Encountered a non-zero number beginning with '0', this is an illegal value in bencoding"}];
		}
		*start = data.length;
	}
	else if ([number componentsSeparatedByString:@"."].count > 2)
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Encountered an integer with multiple floating points, this is an illegal value in bencoding"}];
		}
		*start = data.length;
	}
	++*start;
	return @([number longLongValue]);
}

+ (id)bencodedObjectWithData:(NSData *)data startingAt:(uint64_t *)start error:(NSError *__autoreleasing *)error
{
	id retVal = nil;

	if (*start < data.length)
	{
		switch (((const char *)data.bytes)[*start])
		{
			case 'd':
				retVal = [NSBencodeSerialization bencodedDictionaryWithData:data startingAt:start error:error];
				break;
			case 'l':
				retVal = [NSBencodeSerialization bencodedListWithData:data startingAt:start error:error];
				break;
			case 'i':
				retVal = [NSBencodeSerialization bencodedIntegerWithData:data startingAt:start error:error];
				break;
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				retVal = [NSBencodeSerialization bencodedStringWithData:data startingAt:start error:error];
				break;
			default:
				if (error && !*error)
				{
					*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unexpected character in bencoded data: %c, at index: %llu", ((const char *)data.bytes)[*start], *start]}];
				}
				*start = data.length;
				break;
		}
	}
	else
	{
		if (error && !*error)
		{
			*error = [NSError errorWithDomain:@"bencode" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Empty string"}];
		}
		*start = data.length;
	}

	return retVal;
}

@end
