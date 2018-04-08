//
//  MTTweetsLoader.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTTweetsLoader.h"

#import "MTMacros.h"
#import "MTTimelineTweetsLoader.h"
#import "MTTweetMO+CoreDataClass.h"


static NSString *const kMTtwitterAPIBaseURLString = @"https://api.twitter.com";

static NSString *const kMTtwitterAPIHeaderAuthValue = @"Bearer AAAAAAAAAAAAAAAAAAAAAEuf5QAAAAAAJ5Ocwi6IC94j1EOJAtm4Gk9oSkQ%3DW43A6MLRfqkq7otPfEyiHf4kSJLT1wMunK9CtLUoZ5vKHLmgtP";

static NSString *const kMTtwitterAPIParamCount = @"count";
static NSString *const kMTtwitterAPIParamExcludeReplies= @"exclude_replies";
static NSString *const kMTtwitterAPIParamTrimUser= @"trim_user";

static NSString *const kMTtwitterAPITweetCreationDate = @"created_at";
static NSString *const kMTtwitterAPITweetID = @"id";
static NSString *const kMTtwitterAPITweetText = @"text";
static NSString *const kMTtwitterAPITweetRetweetCount = @"retweet_count";
static NSString *const kMTtwitterAPITweetFavoriteCount = @"favorite_count";

@interface MTTweetsLoader ()
@property (strong, nonatomic) NSURLSession *URLSession;
@property (strong, nonatomic) NSDateFormatter *twitterAPIDateFormatter;

@end

@implementation MTTweetsLoader
@synthesize desiredNumber = _desiredNumber;
@synthesize excludeReplies = _excludeReplies;

+ (instancetype)loaderForTimelineWithScreenName:(NSString *)screenName {
    return [[MTTimelineTweetsLoader alloc] initWithScreenName:screenName];
}

- (instancetype)init {
    self = [super init];
    if (!self) {return nil;}
    
    _desiredNumber = 1;
    _excludeReplies = YES;
    
    return self;
}

- (NSURLSession *)URLSession {
    if (!_URLSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.URLCache = nil;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        _URLSession = session;
    }
    return _URLSession;
}

- (NSDateFormatter *)twitterAPIDateFormatter {
    if (!_twitterAPIDateFormatter) {
        // Taken from https://github.com/twitter/twitter-kit-ios/blob/b6eb49d149b056d826cbc4b53eaeb39a3ebd591e/TwitterCore/TwitterCore/Utilities/TWTRDateFormatters.m
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _twitterAPIDateFormatter = formatter;
    }
    return _twitterAPIDateFormatter;
}

- (NSInteger)countAPIParameter {
    NSInteger count = self.desiredNumber;
    // get more tweets in case if there will be a lot of replies, to avoid multiple requests
    // See docs for `desiredNumber`
    if (self.excludeReplies) count *= 5;
    return count;
}

- (NSDictionary *)URLParameters {
    return @{
             kMTtwitterAPIParamCount:@([self countAPIParameter]),
             kMTtwitterAPIParamExcludeReplies:@(self.excludeReplies),
             kMTtwitterAPIParamTrimUser:@YES,
             };
}

- (NSURL *)requestURL {
    NSURL *URL = [NSURL URLWithString:[self URLPath]
                        relativeToURL:[NSURL URLWithString:kMTtwitterAPIBaseURLString]];
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL
                                             resolvingAgainstBaseURL:YES];
    NSMutableArray *queryItems = [NSMutableArray new];
    [[self URLParameters] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull name, id  _Nonnull value, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        }
        [queryItems addObject:[NSURLQueryItem queryItemWithName:name value:value]];
    }];
    components.queryItems = queryItems.copy;
    return components.URL;
}

- (void)loadTweetsWithFinishBlock:(void(^)(id tweetsInfo))finishBlock {
    NSParameterAssert(finishBlock);
    if (!finishBlock) {return;}
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self requestURL]];
    [request setValue:kMTtwitterAPIHeaderAuthValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id json;
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (error || statusCode != 200) {
            DLog(@"Failed to load tweets. StatusCode:%ld error: %@", (long)statusCode, error);
        } else {
            NSError *serializationError;
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            if (!json) {
                DLog(@"Failed to serialize data to JSON: %@", serializationError);
            } else {
                DLog(@"Did load %ld tweets", (long)[json count]);
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            finishBlock(json);
        }];
    }];
    
    DLog(@"Will request: %@", request.URL);
    [dataTask resume];
}

- (void)enumerateTweetsInfo:(id)tweetsInfo usingBlock:(void(^)(id aTweetInfo))enumarationBlock {
    NSParameterAssert(enumarationBlock);
    if (!enumarationBlock) {return;}
    if (!tweetsInfo) {return;}
    
    if (![tweetsInfo isKindOfClass:[NSArray class]]) {
        ALog(@"TweetsInfo should be an Array");
        return;
    }
    
    NSInteger i = 0;
    for (id aTweetInfo in tweetsInfo) {
        enumarationBlock(aTweetInfo);
        if (++i == self.desiredNumber) break;
    }
    
    if (i != self.desiredNumber) {
        DLog(@"Failed to get desired number of tweets. Won't load more for now");
    }
    
    self.twitterAPIDateFormatter = nil;
}

- (void)fillTweet:(MTTweetMO *)tweet withTweetInfo:(id)aTweetInfo {
    if (![aTweetInfo isKindOfClass:[NSDictionary class]]) {
        ALog(@"aTweetInfo should be a dictionary");
        return;
    }
    
    tweet.identifier = [aTweetInfo[kMTtwitterAPITweetID] longLongValue];
    tweet.text = aTweetInfo[kMTtwitterAPITweetText];
    tweet.favorite_count = [aTweetInfo[kMTtwitterAPITweetFavoriteCount] intValue];
    tweet.retweet_count = [aTweetInfo[kMTtwitterAPITweetRetweetCount] intValue];
    
    NSString *dateString = aTweetInfo[kMTtwitterAPITweetCreationDate];
    tweet.creation_date = [[self twitterAPIDateFormatter] dateFromString:dateString];
}

#pragma mark - Subclassing

- (NSString *)URLPath {
    ALog(@"MUST OVERRIDE");
    return nil;
}

- (NSString *)tweetsCollectionName {
    return nil;
}

@end
