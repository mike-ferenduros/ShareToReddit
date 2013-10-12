//
//  SubredditSelectController.h
//  Chunky Comic Reader
//
//  Created by Michael Ferenduros on 30/09/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STRSession, STRSubredditController;

@protocol STRSubredditDelegate
- (void)subredditController:(STRSubredditController*)ssc didSelectSubreddit:(NSString*)subreddit;
@end

@interface STRSubredditController : UITableViewController <UISearchBarDelegate>
{
	STRSession *							sesh;

	UISearchBar *							searchBar;

	NSArray *								results;	
}

- (id)initWithSession:(STRSession*)sesh;

+ (NSArray*)MRU;
+ (NSArray*)addToMRU:(NSString*)str;

@property (nonatomic,weak)   id<STRSubredditDelegate>		delegate;

@property (nonatomic,retain) NSArray *			suggested;
@property (nonatomic)        BOOL				suggestedOnly;

@end
