//
//  MTMockTweetLoader.h
//  MuskTweets
//
//  Created by Danila Shikulin on 10/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTTweetsLoader.h"

/**
    This class simulates loading of tweets. On each load it returns 5 tweets, first tweet is always new.
    When there are no new tweets, it loads last 5 tweets all the time.
    Keep in mind that tableview keeps visible only latest 5 tweets. So you need to get rid of them to test loading again.
 */
@interface MTMockTweetLoader : MTTweetsLoader
@end
