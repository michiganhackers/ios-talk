//  RBPostCell.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBPostCell.h"
#import "RBPostCellItem.h"
#import "RBPost.h"
#import "UIImageView+AFNetworking.h"

@implementation RBPostCell

+ (CGFloat)heightWithItem:(RETableViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager
{
    return 60.0;
}

- (void)cellWillAppear
{
    RBPost *post = ((RBPostCellItem *)self.item).post;
    self.nameLabel.text = post.title;
    
    [self.thumbnailView setImageWithURL:post.thumbnail];
    if (!post.thumbnail)
        self.nameLabel.frame = CGRectMake(8, self.nameLabel.frame.origin.y, self.frame.size.width-16, self.nameLabel.frame.size.height);
}

@end
