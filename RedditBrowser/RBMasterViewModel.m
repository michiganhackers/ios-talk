//  RBMasterViewModel.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/9/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBMasterViewModel.h"
#import "JCResponseSerializer.h"
#import "RBAPIManager.h"
#import "RBPost.h"

@implementation RBMasterViewModel

- (RACSignal *)postSignal
{
    __block RACSubject *signal = [RACSubject subject];
    
    AFHTTPRequestOperation *op = [[RBAPIManager manager] GET:@"hot.json" parameters:nil
    success:^(AFHTTPRequestOperation *operation, NSArray *posts) {
        
        [signal sendNext:posts];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [signal sendError:error];
    }];
    [op setResponseSerializer:[RBPost arrayResponseSerializerWithRootKeyPath:@"data.children.data"]];
    
    return signal;
}

@end
