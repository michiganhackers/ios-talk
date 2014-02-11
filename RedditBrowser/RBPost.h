//  RBPost.h
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "JCModel.h"

@interface RBPost : JCModel

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *thumbnail;
@property (strong, nonatomic) NSURL *url;

@end
