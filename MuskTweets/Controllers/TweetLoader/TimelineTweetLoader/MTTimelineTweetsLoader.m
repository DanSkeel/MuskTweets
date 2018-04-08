//
//  MTTimelineTweetsLoader.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTTimelineTweetsLoader.h"

#import "MTMacros.h"


static NSString *const kMTtwitterAPIParamScreenName = @"screen_name";

@interface MTTimelineTweetsLoader ()
@property (copy, nonatomic) NSString *screenName;

@end

@implementation MTTimelineTweetsLoader

- (instancetype)init {
    MT_UNAVAILABLE_INITIALIZER
    return [self initWithScreenName:nil];
}

- (instancetype)initWithScreenName:(NSString *)screenName {
    NSParameterAssert(screenName);
    if (!screenName) {return nil;}
    
    self = [super init];
    if (!self) {return nil;}
    
    _screenName = screenName;
    
    return self;
}

- (NSString *)URLPath {
    return @"/1.1/statuses/user_timeline.json";
}

- (NSDictionary *)URLParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[super URLParameters]];
    params[kMTtwitterAPIParamScreenName] = self.screenName;
    return params.copy;
}

- (NSString *)tweetsCollectionName {
    return [@"@" stringByAppendingString:self.screenName];
}

@end
