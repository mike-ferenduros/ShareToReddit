//
//  ShareToRedditController.h
//  ShareToReddit
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STRSession.h"
#import "STRSubredditController.h"

@class ShareToRedditController;

@protocol ShareToRedditControllerDelegate <UINavigationControllerDelegate>

@optional
//'error' may be nil for success, NSCocoaErrorDomain+NSUserCancelledError, or a genuine network or API error
//Delegate should respond by dismissing view-controller
- (void)shareToRedditController:(ShareToRedditController*)controller didCompleteWithError:(NSError*)error;

@end



@interface ShareToRedditController : UINavigationController

- (id)init;
- (void)closeWithError:(NSError*)err;

//The following must be set BEFORE the view-controller is presented.

@property (nonatomic,weak) id<ShareToRedditControllerDelegate> delegate;

//If set, used to prepopulate subreddit selection list
@property (nonatomic,retain) NSArray *		suggestedSubreddits;

//One and only one of these must be set.
@property (nonatomic,retain) NSURL *		url;
@property (nonatomic,retain) UIImage *		image;

@end
