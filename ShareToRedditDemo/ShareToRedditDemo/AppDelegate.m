//
//  AppDelegate.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 12/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

	PhotoVC *vc = [[PhotoVC alloc] init];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
