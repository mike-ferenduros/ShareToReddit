//
//  WebVC.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 17/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "WebVC.h"
#import "ShareToRedditActivity.h"

@implementation WebVC

- (void)loadView
{
	UIWebView *webView = [[UIWebView alloc] init];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
	self.view = webView;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	self.title = @"Loading...";
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	self.title = nil;
}

- (UIWebView*)webView
{
	return (UIWebView*)self.view;
}

- (UIImage*)thumbnail
{
	UIGraphicsBeginImageContext( self.view.bounds.size );
	[self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return thumb;
}

- (void)hidePopover
{
	if( popover )
	{
		[popover dismissPopoverAnimated:NO];
		popover = nil;
	}
}

- (void)showPopover:(UIViewController*)vc fromBBI:(UIBarButtonItem*)bbi
{
	[self hidePopover];
	if( vc )
	{
		popover = [[UIPopoverController alloc] initWithContentViewController:vc];
		[popover presentPopoverFromBarButtonItem:bbi permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void)share:(UIBarButtonItem*)sender
{
	ShareToRedditActivity *str = [ShareToRedditActivity activityWithSubreddits:@[@"test",@"sandbox"]];

	NSURL *url = self.webView.request.URL;
	url.previewImage = self.thumbnail;

	UIActivityViewController *avc = [[UIActivityViewController alloc]
		initWithActivityItems:@[url]
		applicationActivities:@[str]
	];

	[self showPopover:avc fromBBI:sender];
}

@end
