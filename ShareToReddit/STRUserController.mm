//
//  STRUserController.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "STRUserController.h"
#import "STRSession.h"


@implementation STRUserController

- (id)initWithSession:(STRSession*)session
{
    if( self = [super initWithNibName:@"STRUserController" bundle:nil] )
	{
		sesh = session;
		self.title = @"Post as...";
		users = [STRSession cookiedUsers];

		//Would use 'add' system button, but it's basically impossible to tap.
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Account" style:UIBarButtonItemStyleDone target:self action:@selector(addUser:)];
	}
	return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	return YES;
}

- (void)dealloc
{
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
}

- (void)addUser:(UIBarButtonItem*)sender
{
	//FIXME: Lazy, but saves us from doing dynamic updates to the userlist.
	[self.navigationController popViewControllerAnimated:YES];
	[sesh loginDialogForUser:nil password:nil previousError:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return users.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"user"];
	if( !cell )
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user"];

	NSString *user = users[indexPath.row];
	if( sesh.isLoggedIn && [user.lowercaseString isEqualToString:sesh.userName] )
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;

	cell.textLabel.text = users[indexPath.row];

	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}
- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Remove";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( editingStyle == UITableViewCellEditingStyleDelete )
	{
		//FIXME: Animate
		NSString *user = users[indexPath.row];

		if( [sesh isLoggedInAs:user] )
			[sesh logOut];

		[STRSession zapCookieForUser:user];

		users = [STRSession cookiedUsers];
		[self.tableView reloadData];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController popViewControllerAnimated:YES];
	[sesh loginUser:users[indexPath.row]];
}

@end
