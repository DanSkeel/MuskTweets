//
//  AppDelegate.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "AppDelegate.h"

#import "MTDataController.h"
#import "MTRecentTweetsController.h"
#import "MTTweetsLoader.h"
#import "MTTweetsTableViewController.h"


@interface AppDelegate ()
@property (strong, nonatomic) MTTweetsTableViewController *tweetsViewController;
@property (strong, nonatomic) MTDataController *dataController;

@end

@implementation AppDelegate

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _window;
}

- (MTTweetsTableViewController *)tweetsViewController {
    if (!_tweetsViewController) {
        _tweetsViewController = [MTTweetsTableViewController new];
    }
    return _tweetsViewController;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = self.window;
    [window setRootViewController:[self rootViewControllerForWindow]];
    [window makeKeyAndVisible];
    
    self.dataController = [[MTDataController alloc] initWithContainerSetupFinishBlock:^(NSPersistentContainer *persistentContainer) {
        MTTweetsLoader *loader = [MTTweetsLoader loaderForTimelineWithScreenName:@"elonmusk"];        
        
        MTRecentTweetsController *tweetsController =
        [[MTRecentTweetsController alloc] initWithPersistentContainer:persistentContainer
                                                         tweetsLoader:loader];
        tweetsController.tweetsCount = 5;
        
        self.tweetsViewController.tweetsController = tweetsController;
    }];
    
    return YES;
}

#pragma mark - Other methods

- (UIViewController *)rootViewControllerForWindow {
    return [[UINavigationController alloc] initWithRootViewController:self.tweetsViewController];
}

@end
