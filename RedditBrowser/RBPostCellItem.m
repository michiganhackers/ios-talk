//  RBPostItem.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBPostCellItem.h"

@implementation RBPostCellItem

- (id)initWithPost:(RBPost *)post
{
    self = [super init];
    if (self) {
        self.post = post;
    }
    return self;
}

@end
