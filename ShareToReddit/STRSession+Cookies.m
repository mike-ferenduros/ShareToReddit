//
//  STRSession+Cookies.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "STRSession.h"

static NSString *kSTRKeychainService = @"ShareToReddit";


@implementation STRSession (Cookies)

//Could/should we stick the cookies in a shared access-group?

+ (NSString*)cookieForUser:(NSString*)user
{
	NSDictionary *query =
	@{
		(__bridge NSString*)kSecClass : (__bridge NSString*)kSecClassGenericPassword,
		(__bridge NSString*)kSecAttrService : kSTRKeychainService,
		(__bridge NSString*)kSecAttrAccount : user.lowercaseString,
		(__bridge NSString*)kSecReturnData : (__bridge NSNumber*)kCFBooleanTrue
	};

	CFDataRef result = 0;
	OSStatus err = SecItemCopyMatching( (__bridge CFDictionaryRef)query, (CFTypeRef*)(&result) );
	if( err == errSecSuccess )
	{
		NSData *data = (__bridge_transfer NSData*)result;
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	else
	{
		return nil;
	}
}

+ (void)zapCookieForUser:(NSString*)user
{
	NSDictionary *query =
	@{
		(__bridge NSString*)kSecClass : (__bridge NSString*)kSecClassGenericPassword,
		(__bridge NSString*)kSecAttrService : kSTRKeychainService,
		(__bridge NSString*)kSecAttrAccount : user.lowercaseString,
	};
	SecItemDelete( (__bridge CFDictionaryRef)query );
}

+ (void)setCookie:(NSString*)cookie forUser:(NSString*)user
{
	[self zapCookieForUser:user];

	NSDictionary *query =
	@{
		(__bridge NSString*)kSecClass : (__bridge NSString*)kSecClassGenericPassword,
		(__bridge NSString*)kSecAttrService : kSTRKeychainService,
		(__bridge NSString*)kSecAttrAccount : user.lowercaseString,
		(__bridge NSString*)kSecValueData : [cookie dataUsingEncoding:NSUTF8StringEncoding],
	};

	SecItemAdd( (__bridge CFDictionaryRef)query, 0 );
}

+ (NSArray*)cookiedUsers
{
	NSDictionary *query =
	@{
		(__bridge NSString*)kSecClass : (__bridge NSString*)kSecClassGenericPassword,
		(__bridge NSString*)kSecAttrService : kSTRKeychainService,
		(__bridge NSString*)kSecMatchLimit : (__bridge id)kSecMatchLimitAll,
		(__bridge NSString*)kSecReturnAttributes : (__bridge NSNumber*)kCFBooleanTrue
	};

	CFArrayRef result = 0;
	OSStatus err = SecItemCopyMatching( (__bridge CFDictionaryRef)query, (CFTypeRef*)(&result) );
	if( err == errSecSuccess )
	{
		NSArray *items = (__bridge_transfer NSArray*)result;
		NSMutableArray *users = [NSMutableArray arrayWithCapacity:items.count];
		for( NSDictionary *item in items )
		{
			NSString *user = [item objectForKey:(__bridge NSString*)kSecAttrAccount];
			[users addObject:user];
		}
		return [users sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	}
	else
	{
		return nil;
	}
}

+ (void)zapAllUserCookies
{
	NSDictionary *query =
	@{
		(__bridge NSString*)kSecClass : (__bridge NSString*)kSecClassGenericPassword,
		(__bridge NSString*)kSecAttrService : kSTRKeychainService,
	};
	SecItemDelete( (__bridge CFDictionaryRef)query );
}

@end
