//
//  STRImgur.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "ShareToRedditController.h"
#import "STRImgur.h"
#import "STRSession.h"
#import "NSData+Base64.h"



@interface STRImgurUploader : NSObject <NSURLConnectionDataDelegate>
{
	void (^completion)(NSURL*,NSError*);
	void (^progress)(float);
	NSMutableData *data;
}
@end


@implementation STRImgurUploader

- (id)initWithProgress:(void(^)(float))_progress completion:(void(^)(NSURL*,NSError*))_completion
{
	if( self = [super init] )
	{
		progress = _progress;
		completion = _completion;
		data = [NSMutableData data];
	}
	return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if( completion )
	{
		completion( nil, error );
		completion = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)chunk
{
	[data appendData:chunk];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if( progress )
	{
		float frac = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
		progress( frac );
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if( !completion )
		return;

	if( progress )
		progress( 1 );

	NSError *jsonErr = nil;
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
	if( !json )
	{
		completion( nil, jsonErr );
		return;
	}

	if( ((NSNumber*)json[@"success"]).integerValue == 0 )
	{
		completion( nil, nil );
		return;
	}

	NSString *imgId = json[@"data"][@"id"];
	NSURL *outURL = [NSURL URLWithString:[@"http://imgur.com/" stringByAppendingString:imgId]];
	completion( outURL, nil );
}

@end



@implementation STRImgur

+ (void)uploadImage:(UIImage*)img progress:(void(^)(float))progress completion:(void(^)(NSURL*,NSError*))completion
{
	NSData *imgData = UIImageJPEGRepresentation(img,0.8f) ?: UIImagePNGRepresentation(img);
	if( !imgData )
	{
		completion( nil, nil );
		return;
	}

	NSString *mashapeKey = ShareToRedditController.mashapeKey;
	NSString *apiBase = mashapeKey ? @"https://imgur-apiv3.p.mashape.com/" : @"https://api.imgur.com/";

	NSURL *url = [NSURL URLWithString:[apiBase stringByAppendingString:@"3/image"]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"POST";

	NSString *imgurAuth = [@"Client-ID " stringByAppendingString:ShareToRedditController.imgurClientID];
	[req setValue:imgurAuth forHTTPHeaderField:@"Authorization"];

	if( mashapeKey )
		[req setValue:mashapeKey forHTTPHeaderField:@"X-Mashape-Authorization"];

	NSString *img64 = [STRSession urlEncode:imgData.base64EncodedString];
	imgData = nil;

	NSString *body = [@"type=base64&image=" stringByAppendingString:img64];
	img64 = nil;

	req.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
	body = nil;

	STRImgurUploader *uploader = [[STRImgurUploader alloc] initWithProgress:progress completion:completion];

	[NSURLConnection connectionWithRequest:req delegate:uploader];
}

@end
