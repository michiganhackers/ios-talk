//  RBPostItem.h
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RETableViewItem.h"
#import "RBPost.h"

@interface RBPostCellItem : RETableViewItem

@property (strong, nonatomic) RBPost *post;

- (id)initWithPost:(RBPost *)post;

@end
