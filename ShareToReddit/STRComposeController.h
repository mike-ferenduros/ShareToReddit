//
//  ShareToRedditComposeController.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STRSession.h"
#import "STRSubredditController.h"
#import "STRUserController.h"

@interface STRComposeController : UIViewController <STRSubredditDelegate,UITextViewDelegate>
{
	STRSession *			sesh;
	UIPopoverController *	popover;
}

@property (nonatomic,retain) NSString *					subreddit;

@property (nonatomic,retain) IBOutlet UITextView *		postTitle;
@property (nonatomic,retain) IBOutlet UILabel *			postTitlePlaceholder;
@property (nonatomic,retain) IBOutlet UILabel *			charCount;
@property (nonatomic,retain) IBOutlet UIImageView *		imgView;

@property (nonatomic,retain) IBOutlet UIButton *		btnNSFW;
@property (nonatomic,retain) IBOutlet UIButton *		btnSubreddit;
@property (nonatomic,retain) IBOutlet UIButton *		btnUser;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loginActivity;

- (IBAction)toggleNSFW:(UIButton*)sender;
- (IBAction)selectUser:(UIButton*)sender;
- (IBAction)selectSubreddit:(UIButton*)sender;

@end
