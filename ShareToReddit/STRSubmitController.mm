//
//  STRSubmitController.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "ShareToRedditController.h"
#import "STRSubmitController.h"
#import "STRImgur.h"

@implementation STRSubmitController

- (id)initWithSession:(STRSession*)session
{
	if( self = [super initWithNibName:@"STRSubmitController" bundle:nil] )
	{
		sesh = session;
		self.title = @"Posting...";
		self.navigationItem.hidesBackButton = YES;
	}
    return self;
}

- (ShareToRedditController*)rootCon
{
	return (ShareToRedditController*)self.navigationController;
}

- (void)userDone:(UIBarButtonItem*)sender
{
	[self.rootCon closeWithError:nil];
}

- (void)success
{
	self.captchaLabel.hidden = YES;
	self.captchaInput.hidden = YES;
	self.captchaView.hidden = YES;

	[self.progress setProgress:1 animated:YES];
	self.title = @"Success";
	dispatch_after(
		dispatch_time(DISPATCH_TIME_NOW,2*NSEC_PER_SEC),
		dispatch_get_main_queue(),
		^{ [self userDone:nil]; }
	);
}

- (void)fatalError:(NSError*)err
{
	self.captchaLabel.hidden = YES;
	self.captchaInput.hidden = YES;
	self.captchaView.hidden = YES;

	if( err )
	{
		self.errorLabel.text = err.localizedDescription;
		self.errorLabel.hidden = NO;
		self.progress.hidden = YES;
		self.captchaView.hidden = YES;
		self.captchaInput.hidden = YES;
	}
//	[self.navigationItem setHidesBackButton:NO animated:YES];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(userDone:)];
}

- (void)flagNSFW:(NSString*)fullName
{
	[sesh
		requestJSON: @"https://ssl.reddit.com/api/marknsfw"
		post: @{ @"id" : fullName }
		completion: ^( NSDictionary *json, NSError *err )
		{
			//not that we're actually checking if it was a success, but eh, whatever.
			[self success];
		}
	];
}

- (void)fetchCaptcha:(NSString*)iden
{
	[sesh
		requestData: [@"http://reddit.com/captcha/" stringByAppendingString:iden]
		post: nil
		completion: ^( int statusCode, NSData *data, NSError *err )
		{
			if( data )
			{
				if( UIImage *img = [UIImage imageWithData:data] )
				{
					if( !self.captchaView.hidden )
					{
						self.captchaLabel.text = @"Sorry, try again";
					}
					captchaIden = iden;
					self.captchaView.image = img;
					self.captchaInput.text = @"";
					self.captchaLabel.hidden = NO;
					self.captchaInput.hidden = NO;
					self.captchaView.hidden = NO;

					self.captchaInput.enabled = YES;
					[self.captchaInput becomeFirstResponder];
					return;
				}
			}
		}
	];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if( textField.text.length > 0 )
	{
		self.captchaInput.enabled = NO;
		[self submitLink];
	}

	return YES;
}


- (void)submitLink
{
	NSDictionary *query =
	@{
		@"api_type" : @"json",
		@"title" : self.postTitle,
		@"kind" : @"link",
		@"sr" : self.subreddit,
		@"url" : self.postURL.absoluteString
	};

	if( captchaIden )
	{
		NSMutableDictionary *q2 = [NSMutableDictionary dictionaryWithDictionary:query];
		q2[@"iden"] = captchaIden;
		q2[@"captcha"] = self.captchaInput.text;
		query = q2;
	}

	[sesh
		requestJSON: @"https://ssl.reddit.com/api/submit"
		post: query
		completion:^( NSDictionary *json, NSError *err )
		{
			if( !json )
			{
				self.title = @"Post failed";
				[self fatalError:err];
				return;
			}

			if( err )
			{
				if( err.domain==kSTRErrorDomain )
				{
					if( [err.userInfo[kSTRRedditErrorKey] isEqualToString:@"BAD_CAPTCHA"] && json[@"json"][@"captcha"] )
					{
						[self.progress setProgress:0.8f animated:YES];
						[self fetchCaptcha:json[@"json"][@"captcha"]];
						return;
					}
				}
				self.title = @"Post failed";
				[self fatalError:err];
				return;
			}

			NSString *name = json[@"json"][@"data"][@"name"];
			if( self.nsfw && name )
			{
				[self.progress setProgress:0.9f animated:YES];
				[self flagNSFW:name];
			}
			else
			{
				[self success];
			}
		}
	];
}

- (void)uploadImage
{
	[STRImgur uploadImage:self.postImage
	progress:^( float fraction )
	{
		dispatch_async( dispatch_get_main_queue(), ^{ [self.progress setProgress:0.1f+(fraction*0.6f) animated:YES]; } );
	}
	completion:^( NSURL *url, NSError *err )
	{
		if( url )
		{
			self.postURL = url;
			[self submitLink];
		}
		else
		{
			self.title = @"Upload Failed";
			[self fatalError:err];
		}
	}];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.progress setProgress:0 animated:NO];

	if( self.postURL )
	{
		[self.progress setProgress:0.5f animated:YES];
		[self submitLink];
	}
	if( self.postImage )
	{
		[self.progress setProgress:0.1f animated:YES];
		[self uploadImage];
	}
}

@end
