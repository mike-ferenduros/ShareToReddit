//
//  ShareToRedditActivity.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareToRedditController.h"

@interface ShareToRedditActivity : UIActivity <ShareToRedditControllerDelegate>
{
	NSArray *		items;
}

@property (nonatomic,retain) NSArray *		suggestedSubreddits;

+ (ShareToRedditActivity*)activityWithSubreddits:(NSArray*)sr;


@end
