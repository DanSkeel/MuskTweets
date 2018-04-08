//
//  MTRecentTweetsController.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTTweetsControllerP.h"


@interface MTRecentTweetsController : NSObject <MTTweetsControllerP>
@property (nonatomic) NSInteger tweetsCount;

@end
