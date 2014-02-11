//  RBPostCell.h
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RETableViewCell.h"

@class RBPost;

@interface RBPostCell : RETableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailView;

@end
