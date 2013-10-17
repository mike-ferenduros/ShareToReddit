//
//  ShareToRedditActivity.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "ShareToRedditActivity.h"
#import "ShareToRedditController.h"

@implementation ShareToRedditActivity

- (id)init
{
	if( self = [super init] )
	{
	}
	return self;
}

+ (ShareToRedditActivity*)activityWithSubreddits:(NSArray *)sr
{
	ShareToRedditActivity *str = [[ShareToRedditActivity alloc] init];
	str.suggestedSubreddits = sr;
	return str;
}


+ (UIActivityCategory)activityCategory	{ return UIActivityCategoryShare; }
- (NSString*)activityTitle				{ return @"Reddit"; }
- (NSString*)activityType				{ return @"ShareToReddit"; }

- (UIImage*)activityImage
{
	return [UIImage imageNamed:@"reddit7"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	if( ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) )
		return NO;

	BOOL haveImgur = ShareToRedditController.imgurClientID != nil;

	//We can do something with either a UIImage or a NSURL. If both are present, first item in array is used.

	for( id item in activityItems )
	{
		if( haveImgur && [item isKindOfClass:[UIImage class]] )
		{
			return YES;
		}
		else if( [item isKindOfClass:[NSURL class]] )
		{
			return YES;
		}
	}
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	items = activityItems;
}

- (UIViewController*)activityViewController
{
	ShareToRedditController *vc = [[ShareToRedditController alloc] init];
	vc.delegate = self;

	BOOL haveImgur = ShareToRedditController.imgurClientID != nil;

	for( id item in items )
	{
		if( [item isKindOfClass:[NSURL class]] )
		{
			vc.url = (NSURL*)item;
			break;
		}
		else if( haveImgur && [item isKindOfClass:[UIImage class]] )
		{
			vc.image = (UIImage*)item;
		}
	}

	vc.suggestedSubreddits = self.suggestedSubreddits;

	return vc;
}

- (void)shareToRedditController:(ShareToRedditController *)controller didCompleteWithError:(NSError *)error
{
	[self activityDidFinish:error==nil];
}

@end
