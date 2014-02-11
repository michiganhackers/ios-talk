//  RBMasterViewController.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/5/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBMasterViewController.h"
#import "PBWebViewController.h"
#import "RETableViewManager.h"
#import "RBMasterViewModel.h"
#import "RBPostCellItem.h"
#import "RBPost.h"

@interface RBMasterViewController ()
@property (strong, nonatomic) RETableViewManager *manager;
@end

@implementation RBMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Front Page";
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    self.manager[@"RBPostCellItem"] = @"RBPostCell";
    
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    RBMasterViewModel *viewModel = [[RBMasterViewModel alloc] init];
    [viewModel.postSignal subscribeNext:^(NSArray *posts) {
        
        for (RBPost *post in posts) {
            RBPostCellItem *item = [[RBPostCellItem alloc] initWithPost:post];
            
            item.selectionHandler = ^(RBPostCellItem *item) {
                PBWebViewController *browser = [[PBWebViewController alloc] init];
                browser.URL = item.post.url;
                [self.navigationController pushViewController:browser animated:YES];
            };
            
            [section addItem:item];
        }
        
        [self.tableView reloadData];
    }];
}

@end
