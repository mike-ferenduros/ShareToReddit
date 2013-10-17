//
//  FrontVC.m
//  ShareToRedditDemo
//
//  Created by Michael Ferenduros on 17/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "FrontVC.h"
#import "PhotoVC.h"
#import "WebVC.h"

@implementation FrontVC

- (IBAction)doURLDemo:(UIButton *)sender
{
	[self.navigationController pushViewController:[[WebVC alloc] init] animated:YES];
}

- (IBAction)doImageDemo:(UIButton *)sender
{
	[self.navigationController pushViewController:[[PhotoVC alloc] init] animated:YES];
}

@end
