//  RBAppDelegate.m
//  RedditBrowser
//
//  Created by Joseph Constantakis on 2/5/14.
//  Copyright (c) 2014 Joseph Constan. All rights reserved.

#import "RBAppDelegate.h"
#import "RBMasterViewController.h"

@implementation RBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[RBMasterViewController alloc] initWithStyle:UITableViewStylePlain]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
