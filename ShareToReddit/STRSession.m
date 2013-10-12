//
//  STRSession.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "STRSession.h"

static NSString *kSTRDefaultsLastUser = @"ShareToReddit_lastUser";
       NSString *kSTRErrorDomain = @"ShareToReddit";
       NSString *kSTRRedditErrorKey = @"Reddit";


@implementation STRSession



- (void)requestData:(NSString*)urlStr post:(NSDictionary*)post completion:(void(^)(int statusCode,NSData*,NSError*))completion
{
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPShouldHandleCookies = NO;

	[req setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

	if( self.cookie )
		[req setValue:[@"reddit_session=" stringByAppendingString:self.cookie] forHTTPHeaderField:@"Cookie"];

	if( self.user && self.user[@"modhash"] )
		[req setValue:self.user[@"modhash"] forHTTPHeaderField:@"X-Modhash"];

	if( post )
	{
		req.HTTPMethod = @"POST";
		req.HTTPBody = [STRSession queryStringFromDict:post];
	}

	[NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
	^( NSURLResponse *response, NSData *data, NSError *err )
	{
		//If there was a connection error, return that.
		if( err )
		{
			completion( 0, nil, err );
			return;
		}

		NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
		completion( (int)statusCode, data, nil );
	}];
}



- (void)requestJSON:(NSString*)urlStr post:(NSDictionary*)post completion:(void(^)(NSDictionary*,NSError*))completion
{
	[self requestData:urlStr post:post completion:
	^( int statusCode, NSData *data, NSError *err )
	{
		//If there was data-fetch error, return that.
		if( err )
		{
			completion( nil, err );
			return;
		}

		//If returned data is not json, return http error (if any), otherewise blank error
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
		if( !json )
		{
			if( statusCode >= 400 )
			{
				NSString *desc = [NSString stringWithFormat:@"HTTP Error %d", statusCode];
				err = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:@{NSLocalizedDescriptionKey : desc}];
			}
			completion( nil, err );
			return;
		}

		//If returned data specifies API-level errors, return them but ALSO return the json.
		NSArray *rerrs = json[@"json"][@"errors"]; // ?: json[@"errors"]    <- caused compiler to crash... buh?
		if( !rerrs )
			rerrs = json[@"errors"];

		if( rerrs && rerrs.count > 0 )
		{
			NSArray *rerr = rerrs.firstObject;
			NSLog(@"%@",rerr);
			err = [NSError
				errorWithDomain:kSTRErrorDomain
				code:0
				userInfo:@{ kSTRRedditErrorKey : rerr[0]?:@"", NSLocalizedDescriptionKey : rerr[1]?:@"" }
			];
		}
		else
		{
			err = 0;
		}

		completion( json, err );
	}];
}



+ (NSString*)urlEncode:(NSString*)str
{
	return (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(
		0, (__bridge CFStringRef)str, 0,
		(__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8
	);
}

+ (NSData*)queryStringFromDict:(NSDictionary*)dict
{
	NSMutableArray *params = [NSMutableArray arrayWithCapacity:dict.count];
	for( NSString *key in dict )
	{
		NSString *val = [dict objectForKey:key];
		[params addObject:[NSString stringWithFormat:@"%@=%@", [STRSession urlEncode:key], [STRSession urlEncode:val]]];
	}
	NSString *strParams = [params componentsJoinedByString:@"&"];
	return [strParams dataUsingEncoding:NSUTF8StringEncoding];
}



- (void)loginUser:(NSString*)user
{
	if( [self isLoggedInAs:user] )
		return;

	self.isLoggingIn = YES;
	self.user = nil;
	self.cookie = nil;

	NSString *cookie = user ? [STRSession cookieForUser:user] : nil;
	if( cookie )
	{
		[self loginUser:user withCookie:cookie];
	}
	else
	{
		[self loginDialogForUser:user password:nil previousError:nil];
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)av
{
	return [av textFieldAtIndex:0].text.length>0 && [av textFieldAtIndex:1].text.length>0;
}
- (void)alertView:(UIAlertView *)av willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if( buttonIndex==av.firstOtherButtonIndex )
	{
		[self loginUser:[av textFieldAtIndex:0].text withPassword:[av textFieldAtIndex:1].text];
	}
	else
	{
		self.isLoggingIn = NO;
	}
}
- (void)loginDialogForUser:(NSString *)user password:(NSString*)pass previousError:(NSString*)prevErr
{
	if( [self isLoggedInAs:user] )
		return;

	NSString *msg = prevErr;
	NSString *title = prevErr ? @"Login failed" : @"Add Reddit Account";
	UIAlertView *dbox = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in", nil];

	dbox.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
	[dbox textFieldAtIndex:0].text = user;
	[dbox textFieldAtIndex:0].placeholder = @"Username";
	[dbox textFieldAtIndex:1].text = pass;

	[dbox show];
}

- (void)loginUser:(NSString*)user withPassword:(NSString*)pass
{
	user = [user stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	pass = [pass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if( [self isLoggedInAs:user] )
		return;

	self.isLoggingIn = YES;
	self.user = nil;
	self.cookie = nil;

	[self
		requestJSON: @"https://ssl.reddit.com/api/login"
		post: @{
			@"api_type" : @"json",
			@"user" : user,
			@"passwd" : pass,
			@"rem" : @"True"
		}
		completion: ^( NSDictionary *json, NSError *err )
		{
			if( err )
			{
				[self loginDialogForUser:user password:pass previousError:err.localizedDescription];
				return;
			}
				
			NSString *cookie = json[@"json"][@"data"][@"cookie"];
			if( !cookie )
			{
				[self loginDialogForUser:user password:pass previousError:@"Error logging in"];
				return;
			}

			[self loginUser:user withCookie:cookie];
		}
	];
}

- (void)loginUser:(NSString*)user withCookie:(NSString *)cookie
{
	if( [self isLoggedInAs:user] )
		return;

	self.isLoggingIn = YES;
	self.user = nil;
	self.cookie = cookie;		//just for this request

	[self
		requestJSON: @"http://reddit.com/api/me.json"
		post: nil
		completion: ^( NSDictionary *json, NSError *err )
		{
			if( err || !json[@"data"] )
			{
				self.isLoggingIn = NO;
				return;
			}
			
			self.cookie = cookie;
			self.user = json[@"data"];
			self.isLoggingIn = NO;
			[STRSession setCookie:cookie forUser:self.user[@"name"]];
			[[NSUserDefaults standardUserDefaults] setObject:self.user[@"name"] forKey:kSTRDefaultsLastUser];
		}
	];

	self.cookie = nil;			//not verified good yet, so don't keep around
}

- (BOOL)isLoggedIn
{
	return self.user && self.cookie;
}

- (BOOL)isLoggedInAs:(NSString*)user
{
	return user && self.isLoggedIn && [self.userName.lowercaseString isEqualToString:user.lowercaseString];
}

- (void)logOut
{
	self.user = nil;
	self.cookie = nil;
}

- (NSString*)userName
{
	return self.user ? self.user[@"name"] : nil;
}

- (NSString*)loginLastUser
{
	NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:kSTRDefaultsLastUser];
	if( user )
	{
		NSString *cookie = [STRSession cookieForUser:user];
		if( cookie )
		{
			[self loginUser:user withCookie:cookie];
			return user;
		}
	}
	return nil;
}

- (id)init
{
	if( self = [super init] )
	{
		NSDictionary *plist = [[NSBundle mainBundle] infoDictionary];
		self.userAgent = [NSString stringWithFormat:@"%@ %@ / ShareToRedditController", plist[@"CFBundleIdentifier"], plist[@"CFBundleShortVersionString"]];
	}
	return self;
}

@end
