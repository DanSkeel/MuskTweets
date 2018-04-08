//
//  MTTimelineTweetsLoader.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTTweetsLoader.h"


@interface MTTimelineTweetsLoader : MTTweetsLoader

- (instancetype)initWithScreenName:(NSString *)screenName NS_DESIGNATED_INITIALIZER;
@end
