//
//  PhotoVC.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 12/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "PhotoVC.h"
#import "ShareToRedditActivity.h"

@implementation PhotoVC

- (void)loadView
{
	self.view = [[UIImageView alloc] init];
	self.view.contentMode = UIViewContentModeScaleAspectFit;

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pick:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (UIImageView*)imageView
{
	return (UIImageView*)self.view;
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

- (void)pick:(UIBarButtonItem*)sender
{
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self showPopover:picker fromBBI:sender];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
	self.imageView.image = img;
	self.navigationItem.rightBarButtonItem.enabled = img!=nil;
	[self hidePopover];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self hidePopover];
}

- (void)share:(UIBarButtonItem*)sender
{
	UIActivity *str = [ShareToRedditActivity activityWithSubreddits:@[@"test",@"sandbox"]];

	UIActivityViewController *avc = [[UIActivityViewController alloc]
		initWithActivityItems:@[self.imageView.image]
		applicationActivities:@[str]
	];

	[self showPopover:avc fromBBI:sender];
}

@end
