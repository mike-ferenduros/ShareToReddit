//
//  PhotoVC.h
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 12/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoVC : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate>
{
	UIPopoverController *popover;
}

@end
