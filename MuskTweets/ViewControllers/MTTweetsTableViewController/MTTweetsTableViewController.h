//
//  MTTweetsTableViewController.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTTweetsControllerP.h"


@interface MTTweetsTableViewController : UITableViewController
@property (strong, nonatomic) NSObject<MTTweetsControllerP> *tweetsController;

@end
