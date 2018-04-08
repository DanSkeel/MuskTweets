//
//  MTTweetsLoader.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTTweetsLoaderP.h"


@interface MTTweetsLoader : NSObject <MTTweetsLoaderP>

+ (instancetype)loaderForTimelineWithScreenName:(NSString *)screenName;
- (NSString *)URLPath;
- (NSDictionary *)URLParameters NS_REQUIRES_SUPER;
@end
