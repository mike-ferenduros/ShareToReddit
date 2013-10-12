//
//  ShareToRedditComposeController.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "ShareToRedditController.h"
#import "STRComposeController.h"
#import "STRSubmitController.h"




@implementation STRComposeController

- (id)init
{
	if( self = [super initWithNibName:@"STRComposeController" bundle:nil] )
	{
//		[STRSession zapAllUserCookies];

		self.title = @"Reddit";

		sesh = [[STRSession alloc] init];
		[sesh addObserver:self forKeyPath:@"isLoggingIn" options:0 context:nil];
		[sesh addObserver:self forKeyPath:@"user" options:0 context:nil];

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userCancel:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(userPost:)];
		self.navigationItem.rightBarButtonItem.enabled = NO;

		self.subreddit = STRSubredditController.MRU.firstObject;
	}
    return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	return YES;
}

- (void)dealloc
{
	if( popover )
	{
		[popover dismissPopoverAnimated:NO];
		popover = nil;
	}

	[sesh removeObserver:self forKeyPath:@"isLoggingIn"];
	[sesh removeObserver:self forKeyPath:@"user"];
}

- (ShareToRedditController*)rootCon
{
	ShareToRedditController *con = (ShareToRedditController*)self.navigationController;
	return [con isKindOfClass:[ShareToRedditController class]] ? con : nil;
}

- (void)updatePostButton
{
	if( !self.subreddit || !sesh.isLoggedIn || self.postTitle.text.length==0 )
		self.navigationItem.rightBarButtonItem.enabled = NO;
	else
		self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( object == sesh && self.view )
	{
		if( sesh.isLoggingIn )
		{
			self.btnUser.hidden = YES;
			self.loginActivity.hidden = NO;
			[self.btnUser setTitle:nil forState:UIControlStateNormal];
		}
		else
		{
			self.btnUser.hidden = NO;
			self.loginActivity.hidden = YES;
			[self.btnUser setTitle:(sesh.userName ?: @"Post As...") forState:UIControlStateNormal];
		}
	}
	[self updatePostButton];
}

- (void)updateUI
{
	NSString *sr = self.subreddit ? [@"/r/" stringByAppendingString:self.subreddit] : @"Subreddit...";
	[self.btnSubreddit setTitle:sr forState:UIControlStateNormal];

	[self updatePostButton];
	[self observeValueForKeyPath:@"isLoggingIn" ofObject:sesh change:nil context:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if( self.rootCon.image )
	{
		self.imgView.image = self.rootCon.image;
	}
	else if( self.rootCon.url )
	{
		//Umm...dunno.
		//Set a generic compass icon here?
		//Fetch the HTML, look for an appropriate image and load that?
		//Special-case image-loader for known URLs (imgur, youtube etc)?
		//Replace with a UIWebView with user-interaction disabled?
	}

	[sesh loginLastUser];

	[self updateUI];
}

- (void)textViewDidChange:(UITextView *)textView
{
	int remaining = 300 - textView.text.length;
	self.charCount.text = [NSString stringWithFormat:@"%d",remaining];

	if( remaining < 0 )
		self.charCount.textColor = [UIColor redColor];
	else
		self.charCount.textColor = [UIColor darkGrayColor];

	[self updatePostButton];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	self.postTitlePlaceholder.hidden = YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.postTitlePlaceholder.hidden = textView.text.length>0;
}



- (void)userCancel:(UIBarButtonItem*)sender
{
	[self.rootCon closeWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)userPost:(UIBarButtonItem*)sender
{
	STRSubmitController *submit = [[STRSubmitController alloc] initWithSession:sesh];

	submit.postImage = self.rootCon.image;
//	submit.postURL = [NSURL URLWithString:@"http://imgur.com/H6itLWl"];

	submit.postTitle = self.postTitle.text;
	submit.subreddit = self.subreddit;
	submit.nsfw = self.btnNSFW.selected;

	[self.rootCon pushViewController:submit animated:YES];
}

- (IBAction)selectSubreddit:(UIButton*)sender
{
	if( popover )
	{
		[popover dismissPopoverAnimated:NO];
		popover = nil;
	}

	STRSubredditController *subCon = [[STRSubredditController alloc] initWithSession:sesh];

	NSArray *suggested = [STRSubredditController.MRU arrayByAddingObjectsFromArray:self.rootCon.suggestedSubreddits];
	subCon.suggested = [NSOrderedSet orderedSetWithArray:suggested].array;

	subCon.delegate = self;

	popover = [[UIPopoverController alloc] initWithContentViewController:subCon];
	popover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 90, 10);
	[popover presentPopoverFromRect:CGRectInset(sender.bounds,40,0) inView:sender permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}
- (void)subredditController:(STRSubredditController *)ssc didSelectSubreddit:(NSString *)sr
{
	if( popover )
	{
		[popover dismissPopoverAnimated:NO];
		popover = nil;
	}
	if( sr )
	{
		[STRSubredditController addToMRU:sr];
		self.subreddit = sr;
		[self updateUI];
	}
}

- (IBAction)selectUser:(UIButton *)sender
{
	if( [STRSession cookiedUsers].count > 0 )
	{
		STRUserController *userCon = [[STRUserController alloc] initWithSession:sesh];
		[self.rootCon pushViewController:userCon animated:YES];
	}
	else
	{
		[sesh loginDialogForUser:nil password:nil previousError:nil];
	}
}

- (IBAction)toggleNSFW:(UIButton*)sender
{
	sender.selected = !sender.selected;
}

@end
