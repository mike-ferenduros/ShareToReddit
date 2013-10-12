//
//  ShareToRedditController.m
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "ShareToRedditController.h"
#import "STRComposeController.h"



@implementation ShareToRedditController

- (id)init
{
	STRComposeController *compose = [[STRComposeController alloc] init];
	if( self = [super initWithRootViewController:compose] )
	{
		self.modalPresentationStyle = UIModalPresentationFormSheet;
		self.navigationBar.translucent = NO;
	}
    return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.view.superview.backgroundColor = [UIColor clearColor];
	self.view.layer.cornerRadius = 10.0f;
	self.view.layer.masksToBounds = YES;

	self.view.bounds = CGRectMake( 0, 0, 600, 244 );
	self.view.center = CGPointMake( self.view.superview.bounds.size.width*0.5f, 200 );
}



- (void)closeWithError:(NSError *)err
{
	if( self.delegate && [self.delegate respondsToSelector:@selector(shareToRedditController:didCompleteWithError:)] )
	{
		[self.delegate shareToRedditController:self didCompleteWithError:err];
	}
}

@end
