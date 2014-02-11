//  RBAPIManager.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/10/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBAPIManager.h"

@implementation RBAPIManager

- (NSURL *)baseURL
{
    return [NSURL URLWithString:@"http://reddit.com/"];
}

@end
