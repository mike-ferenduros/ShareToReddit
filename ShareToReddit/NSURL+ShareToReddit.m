//
//  NSURL+ShareToReddit.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 17/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "NSURL+ShareToReddit.h"
#import <objc/runtime.h>


static const char *kSTRURLImageKey = "kSTRURLImageKey";

@implementation NSURL (ShareToReddit)

- (void)setPreviewImage:(UIImage*)img
{
	objc_setAssociatedObject( self, kSTRURLImageKey, img, OBJC_ASSOCIATION_RETAIN );
}

- (UIImage*)previewImage
{
	return objc_getAssociatedObject( self, kSTRURLImageKey );
}

@end
