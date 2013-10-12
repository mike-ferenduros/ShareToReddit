//
//  STRSubmitController.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STRSession;

@interface STRSubmitController : UIViewController <UITextFieldDelegate>
{
	STRSession *	sesh;

	NSString *		captchaIden;
	NSString *		captchaResult;
}

- (id)initWithSession:(STRSession*)session;

@property (nonatomic,retain) UIImage * postImage;
@property (nonatomic,retain) NSURL *   postURL;
@property (nonatomic,retain) NSString *postTitle;
@property (nonatomic,retain) NSString *subreddit;
@property (nonatomic)        BOOL      nsfw;

@property (nonatomic,retain) IBOutlet UIProgressView *	progress;
@property (nonatomic,retain) IBOutlet UILabel *			captchaLabel;
@property (nonatomic,retain) IBOutlet UIImageView *		captchaView;
@property (nonatomic,retain) IBOutlet UITextField *		captchaInput;
@property (nonatomic,retain) IBOutlet UILabel *			errorLabel;

@end
