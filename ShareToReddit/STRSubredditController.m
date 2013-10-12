//
//  SubredditSelectController.m
//  ShareToReddit
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import "STRSubredditController.h"
#import "STRSession.h"



@implementation STRSubredditController

+ (NSArray*)MRU
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"ShareToReddit_MRU"] ?: @[];
}

+ (NSArray*)addToMRU:(NSString*)str
{
	if( !str )
		return self.MRU;

	NSMutableArray *m = [NSMutableArray arrayWithArray:self.MRU];
	[m removeObject:str];
	[m insertObject:str atIndex:0];
	while( m.count > 10 )
		[m removeLastObject];

	NSArray *mru = [NSArray arrayWithArray:m];
	[[NSUserDefaults standardUserDefaults] setObject:mru forKey:@"ShareToReddit_MRU"];
	return mru;
}

- (id)initWithSession:(STRSession*)session;
{
	if( self = [super initWithStyle:UITableViewStylePlain] )
	{
		sesh = session;
		self.preferredContentSize = CGSizeMake(300,200);
	}
    return self;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
	return YES;
}

- (void)viewDidLoad
{
	if( !self.suggestedOnly )
	{
		searchBar = [[UISearchBar alloc] init];
		[searchBar sizeToFit];
		searchBar.delegate = self;
		self.tableView.tableHeaderView = searchBar;
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if( searchText.length == 0 )
	{
		results = nil;
		[self.tableView reloadData];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sbar
{
	results = @[];
	[self.tableView reloadData];
	
	[sesh
		requestJSON: @"https://ssl.reddit.com/api/search_reddit_names.json"
		post: @{@"query" : searchBar.text}
		completion:^( NSDictionary *json, NSError *err )
		{
			results = json[@"names"];
			[self.tableView reloadData];
		}
	];
}


- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	NSArray *rows = results ?: self.suggested;
	return rows ? rows.count : 0;
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"plain"];
	if( !cell )
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"subreddit"];

	NSArray *rows = results ?: self.suggested;
	cell.textLabel.text = [@"/r/" stringByAppendingString:[rows objectAtIndex:indexPath.row]];

	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *rows = results ?: self.suggested;

	if( self.delegate )
		[self.delegate subredditController:self didSelectSubreddit:rows[indexPath.row]];
}

@end
