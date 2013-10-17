//
//  AppDelegate.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 12/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "AppDelegate.h"
#import "FrontVC.h"
#import "ShareToRedditController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//	#warning You should set an Imgur Client ID here for image uploads to work
	ShareToRedditController.imgurClientID = @"fde173d45e97ad6";
	ShareToRedditController.mashapeKey = @"scX2Tqc85AyyaV065UJoIaLjQdQAHbbq";

	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

	FrontVC *front = [[FrontVC alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:front];
	nav.navigationBar.translucent = NO;
	self.window.rootViewController = nav;

	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
