//
//  STRUserController.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STRSession;

@interface STRUserController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
	STRSession *		sesh;
	NSArray *			users;
}

- (id)initWithSession:(STRSession*)sesh;

@property (nonatomic,retain) IBOutlet UITableView *tableView;

@end
