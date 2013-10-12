//
//  RedditSession.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STRSession;

extern NSString *kSTRErrorDomain;
extern NSString *kSTRRedditErrorKey;

@interface STRSession : NSObject <UIAlertViewDelegate>

	+ (NSString*)urlEncode:(NSString*)str;
	+ (NSData*)queryStringFromDict:(NSDictionary*)dict;


	- (void)requestData:(NSString*)urlStr post:(NSDictionary*)post completion:(void(^)(int statusCode,NSData*,NSError*))completion;
	- (void)requestJSON:(NSString*)urlStr post:(NSDictionary*)post completion:(void(^)(NSDictionary*,NSError*))completion;


	//Reddit says this should be descriptive
	@property (nonatomic,retain) NSString *						userAgent;

	//Set if we're currently trying to log in. If set, user=cookie=nil.
	@property (nonatomic) BOOL									isLoggingIn;

	//Either both of these are set or neither.
	@property (nonatomic,retain) NSDictionary *					user;
	- (NSString*)userName;

	@property (nonatomic,retain) NSString *						cookie;

	//If last known user exists and has cookie, start logging them in and return username
	- (NSString*)loginLastUser;

	//If user has a cookie, hand it off to loginUser:withCookie:. Else hand off to loginUserwithDialog
	- (void)loginUser:(NSString*)user;

	//Throw up dialog-box asking for user/pass, hand them off to loginUser:withPassword:
	- (void)loginDialogForUser:(NSString*)user password:(NSString*)pass previousError:(NSString*)prevErr;

	//Get a cookie, hand it off to loginUser:withCookie
	- (void)loginUser:(NSString*)user withPassword:(NSString*)pass;

	//Test cookie by getting user info, save user to keychain+defaults if successful
	- (void)loginUser:(NSString*)user withCookie:(NSString*)cookie;

	- (BOOL)isLoggedIn;
	- (BOOL)isLoggedInAs:(NSString*)user;
	- (void)logOut;

@end



@interface STRSession (Cookies)

	//Keychain wrapper.
	+ (NSArray*)cookiedUsers;		//array of NSString* usernames
	+ (NSString*)cookieForUser:(NSString*)user;
	+ (void)setCookie:(NSString*)cookie forUser:(NSString*)user;
	+ (void)zapCookieForUser:(NSString*)user;

	//You should probably stick button somewhere in your settings that invokes this.
	+ (void)zapAllUserCookies;

@end
